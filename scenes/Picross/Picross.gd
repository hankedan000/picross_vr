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

# a map of the all the visible cubes keyed by (x,y,z) index
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
		
	var key = _make_key(x,y,z)
	if not _data.shape.has(key):
		_data.shape.push_back(key)
	
	# update shape bounds
	_width = max(_width,x+1)
	_height = max(_height,y+1)
	_depth = max(_depth,z+1)
	
# called when player removes a cube from picross
# returns false if removal was a mistake (ie. removed a cube that's part of the
# solution); true otherwise
func remove_cube(cube_key):
	var cube = _cubes_by_xyz.get(cube_key,null)
	if cube and is_a_solved_cube(cube_key):
		cube.state = BaseCube.State.Mistake
		return false
	elif cube:
		cube.queue_free()
		_cubes_by_xyz.erase(cube_key)
	return true
	
# returns true if the cube referenced by the key is part of the final solution
func is_a_solved_cube(cube_key):
	return _data.shape.has(cube_key)
	
func load_unsolved_shape(puzzle: PicrossPuzzle):
	_clear_all_cubes()
	
	print("Loading '%s' unsolved shape" % puzzle.name())
	var dims = puzzle.dims()
	
	# load cubes that bound the final shape
	for x in range(dims[0]):
		for y in range(dims[1]):
			for z in range(dims[2]):
				var cube = _add_cube(x,y,z)
				if cube is BaseCube:
					cube.state= BaseCube.State.Unsolved
					cube.clear_labels()
					
	# h x d hints
	var hd_hints = puzzle.hints()[0]
	for j in range(dims[1]):
		for k in range(dims[2]):
			var hint = hd_hints[j][k]
			if hint != null:
				for i in range(dims[0]):
					var key = _make_key(i,j,k)
					var cube : BaseCube = _cubes_by_xyz.get(key,null)
					if cube != null:
						cube.set_lr_label(hint.num,hint.type)
					
	# w x d hints
	var wd_hints = puzzle.hints()[1]
	for i in range(dims[0]):
		for k in range(dims[2]):
			var hint = wd_hints[i][k]
			if hint != null:
				for j in range(dims[1]):
					var key = _make_key(i,j,k)
					var cube : BaseCube = _cubes_by_xyz.get(key,null)
					if cube != null:
						cube.set_tb_label(hint.num,hint.type)
					
	# w x h hints
	var wh_hints = puzzle.hints()[2]
	for i in range(dims[0]):
		for j in range(dims[1]):
			var hint = wd_hints[i][j]
			if hint != null:
				for k in range(dims[2]):
					var key = _make_key(i,j,k)
					var cube : BaseCube = _cubes_by_xyz.get(key,null)
					if cube != null:
						cube.set_fb_label(hint.num,hint.type)

const FACE_TYPE_LUT = {
	"+x" : "right",
	"-x" : "left",
	"+y" : "top",
	"-y" : "bottom",
	"+z" : "front",
	"-z" : "back"
}

func load_solved_shape(puzzle: PicrossPuzzle):
	_clear_all_cubes()
	
	# load the final shape
	print("Loading '%s'" % puzzle.name())
	var shape : PicrossShape = PicrossSolver.bruteForceSolve(puzzle)
	if shape == null:
		print("'%s' is not solvable!" % puzzle.name())
		return
	
	var dims = shape.dims()
	for i in range(dims[0]):
		for j in range(dims[1]):
			for k in range(dims[2]):
				var c = shape.getCell(i,j,k)
				if c == PicrossTypes.CellState.painted:
					var cube = _add_cube(i,j,k)
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
	new_cube.key = key
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
