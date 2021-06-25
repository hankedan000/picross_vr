extends OQClass_GrabbableRigidBody
class_name Picross

export var no_gravity = false
export var BaseCubeScene : PackedScene = null

# FIXME make this dynamic it doesn't change with the origina size of the BaseCube.mesh
const CUBE_WIDTH = 0.02

onready var grab_shape = $grab_shape

# absolute bounds of the 
var _width = 0
var _height = 0
var _depth = 0

var _data = {
	"name" : "",
	"shape" : [],
	"hint_groups" : [],
	"fills" : []
}

var _cubes_by_xyz = {}

func _ready():
	if no_gravity:
		gravity_scale = 0

func from_file(filepath : String):
	vr.log_info("Loading picross from file %s" % filepath)
	var data = vr.load_json_file(filepath)
	
	reset()
	for cube in data['shape']:
		add_cube(cube[0],cube[1],cube[2])
		
	_data.fills = data.fills
	_data.hint_groups = data.hint_groups

func reset():
	_clear_all_cubes()
	_data = {
		"name" : "",
		"shape" : [],
		"hint_groups" : [],
		"fills" : []
	}
		
	_width = 0
	_height = 0
	_depth = 0
	_update_grab_shape()
		
func add_cube(x,y,z):
	if x < 0 || y < 0 || z < 0:
		vr.log_warning('x,y,z must be >= 0. x = %d; y = %d; z = %d;' % [x,y,z])
		return
		
	_data.shape.push_back([x,y,z])
	
	# update shape bounds
	_width = max(_width,x+1)
	_height = max(_height,y+1)
	_depth = max(_depth,z+1)
	
func load_unsolved_shape():
	_clear_all_cubes()
	
	# load cubes that bound the final shape
	for x in range(_width):
		for y in range(_height):
			for z in range(_depth):
				var cube = _add_cube(x,y,z)
				if cube is BaseCube:
					cube.state= BaseCube.State.Unsolved
					cube.clear_labels()
					
	for hint_group in _data['hint_groups']:
		for hint in hint_group['hints']:
			var value = hint['value']
			var type = hint['type']
			if hint_group['axis'] == 'x':
				var y = hint['location']['y']
				var z = hint['location']['z']
				for x in range(_width):
					var key = _make_key(x,y,z)
					var cube : BaseCube = _cubes_by_xyz.get(key,null)
					if cube != null:
						cube.set_lr_label(value,type)
			elif hint_group['axis'] == 'y':
				var x = hint['location']['x']
				var z = hint['location']['z']
				for y in range(_height):
					var key = _make_key(x,y,z)
					var cube : BaseCube = _cubes_by_xyz.get(key,null)
					if cube != null:
						cube.set_tb_label(value,type)
			elif hint_group['axis'] == 'z':
				var x = hint['location']['x']
				var y = hint['location']['y']
				for z in range(_depth):
					var key = _make_key(x,y,z)
					var cube : BaseCube = _cubes_by_xyz.get(key,null)
					if cube != null:
						cube.set_fb_label(value,type)

const FACE_TYPE_LUT = {
	"+x" : "right",
	"-x" : "left",
	"+y" : "top",
	"-y" : "bottom",
	"+z" : "front",
	"-z" : "back"
}

func load_solved_shape():
	_clear_all_cubes()
	
	# load the final shape
	for cube_dat in _data.shape:
		var cube = _add_cube(cube_dat[0],cube_dat[1],cube_dat[2])
		if cube:
			cube.state = BaseCube.State.Solved
		
	# load fill textures
	var fills = _data.get('fills',[])
	for fill in fills:
		var cube = fill.cube
		
		# start by fill whole cube with color if it's defined
		if fill.has('color'):
			var fill_color = Color(fill['color'])
			_set_cube_fill(cube[0],cube[1],cube[2],fill_color)
		
		# iterate over all faces and fill as defined
		var faces = fill.get('faces',[])
		for face_fill in faces:
			var face = FACE_TYPE_LUT[face_fill['face']]
			var fill_color = Color(face_fill['color'])
			_set_cube_face_fill(cube[0],cube[1],cube[2],face,fill_color)

static func _make_key(x,y,z):
	return [int(x),int(y),int(z)]

func _add_cube(x,y,z):
	var key = _make_key(x,y,z)
	if _cubes_by_xyz.has(key):
		vr.log_warning("duplicate add of cube meash at x,y,z = %s" % [key])
		return null
	
	var new_cube := BaseCubeScene.instance()
	var origin = Vector3(int(x),int(y),int(z)) * CUBE_WIDTH
	new_cube.transform = Transform(Basis(), origin)
	$cubes.add_child(new_cube)
	_cubes_by_xyz[key] = new_cube
	_update_grab_shape()
	return new_cube

# resize the collision shape based on the current width, height, and depth
func _update_grab_shape():
	grab_shape.shape.extents.x = _width * CUBE_WIDTH / 2.0
	grab_shape.shape.extents.y = _height * CUBE_WIDTH / 2.0
	grab_shape.shape.extents.z = _depth * CUBE_WIDTH / 2.0
	
	# place colision shape in middle of picross
	var half_cube_width = CUBE_WIDTH / 2.0
	grab_shape.transform.origin.x = _width * CUBE_WIDTH / 2.0 - half_cube_width
	grab_shape.transform.origin.y = _height * CUBE_WIDTH / 2.0 - half_cube_width
	# z is already aligned
	
func _set_cube_fill(x,y,z,fill_color):
	var key = [x,y,z]
	if _cubes_by_xyz.has(key):
		var cube = _cubes_by_xyz[key]
		for mesh_inst in cube.get_node("meshes").get_children():
			var mat = mesh_inst.get_surface_material(0)
			if mat is SpatialMaterial:
				mat.albedo_color = fill_color
			else:
				vr.log_warning("can only set fill on SpatialMaterials")
	else:
		vr.log_warning("unknown cube mesh at %s. can't set fill" % [key])

# face can be 'front','back','top','bottom','left', or 'right'
func _set_cube_face_fill(x,y,z,face,fill_color):
	var key = [x,y,z]
	if _cubes_by_xyz.has(key):
		var cube = _cubes_by_xyz[key]
		var mesh_inst = cube.get_node("meshes").get_node(face)
		var mat = mesh_inst.get_surface_material(0)
		if mat is SpatialMaterial:
			mat.albedo_color = fill_color
		else:
			vr.log_warning("can only set fill on SpatialMaterials")
	else:
		vr.log_warning("unknown cube mesh at %s. can't set fill" % [key])
	
func _clear_all_cubes():
	for cube in $cubes.get_children():
		cube.queue_free()
	_cubes_by_xyz = {}
	
func _process(_delta):
	if no_gravity:
		gravity_scale = 0
	else:
		gravity_scale = 1
