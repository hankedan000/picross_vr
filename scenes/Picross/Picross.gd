extends OQClass_GrabbableRigidBody
class_name Picross

export var no_gravity = false
export var BaseCubeScene : PackedScene = null

# FIXME make this dynamic it doesn't change with the origina size of the BaseCube.mesh
const CUBE_WIDTH = 0.02

onready var grab_shape = $grab_shape

var puzzle : PicrossPuzzle = null;
var solve_shape : PicrossShape = null;

var _solution_keys = []

# a map of the all the visible cubes keyed by (x,y,z) index
var _cubes_by_xyz = {}

func _ready():
	if no_gravity:
		gravity_scale = 0

func load_from_json_file(filepath):
	var puzzle_json = vr.load_json_file(filepath)
	load_from_json(puzzle_json)
	
func load_from_json(puzzle_json):
	self.puzzle = PicrossPuzzleUtils.fromJSON(puzzle_json)
	vr.log_info("Loading picross '%s'" % puzzle.name())
	
	self.solve_shape = PicrossSolver.bruteForceSolve(puzzle)
	
	_solution_keys = []
	if self.solve_shape:
		var dims = self.puzzle.dims()
		for i in dims[0]:
			for j in dims[1]:
				for k in dims[2]:
					if self.solve_shape.getCell(i,j,k) == PicrossTypes.CellState.painted:
						var key = _make_key(i,j,k)
						if ! _solution_keys.has(key):
							_solution_keys.append(key)
	
	_clear_all_cubes()
	_update_grab_shape()
		
# called when player removes a cube from picross
#
# cube_kay -> the [i,j,k] tuple corresponding to the cube to remove
# completely -> set to true to remove the cube and it's mesh, otherwise the
# 	cube will just be hidden
#
# returns false if removal was a mistake (ie. removed a cube that's part of the
# solution); true otherwise
func remove_cube(cube_key,completely=false):
	var cube = _cubes_by_xyz.get(cube_key,null)
	if cube and is_a_solved_cube(cube_key):
		cube.state = BaseCube.State.Mistake
		return false
	elif cube:
		if completely:
			cube.queue_free()
			_cubes_by_xyz.erase(cube_key)
			# FIXME need to update the culling logic to support cubes being
			# fully removed from the scene tree and not just hidden. existing
			# culling logic assume the picross is composed to a block of cubes
			# which isn't true when in "create" mode.
#			_cull_hidden_nodes()
		else:
			cube.hide()
			_cull_hidden_nodes()
	return true
	
# returns true if the cube referenced by the key is part of the final solution
func is_a_solved_cube(cube_key):
	return _solution_keys.has(cube_key)
	
func load_unsolved_shape():
	_clear_all_cubes()
	
	if puzzle == null:
		vr.log_error("No puzzle loaded! Can't load unsolved shape.")
		return
	
	vr.log_info("Loading '%s' unsolved shape" % puzzle.name())
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
			var hint = wh_hints[i][j]
			if hint != null:
				for k in range(dims[2]):
					var key = _make_key(i,j,k)
					var cube : BaseCube = _cubes_by_xyz.get(key,null)
					if cube != null:
						cube.set_fb_label(hint.num,hint.type)
						
	_cull_hidden_nodes()

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
	
	if puzzle == null:
		vr.log_error("No puzzle loaded! Can't load solved shape.")
		return
	
	# load the final shape
	vr.log_info("Loading '%s'" % puzzle.name())
	if solve_shape == null:
		vr.log_error("'%s' is not solvable!" % puzzle.name())
		return
	
	var dims = solve_shape.dims()
	for i in range(dims[0]):
		for j in range(dims[1]):
			for k in range(dims[2]):
				var c = solve_shape.getCell(i,j,k)
				if c == PicrossTypes.CellState.painted:
					var cube = _add_cube(i,j,k)
					cube.state = BaseCube.State.Solved
		
	# load fill textures
#	var fills = _data.get('fills',[])
#	for fill in fills:
#		var cube = fill.cube
#
#		# start by fill whole cube with color if it's defined
#		if fill.has('color'):
#			var fill_color = Color(fill['color'])
#			_set_cube_fill(cube[0],cube[1],cube[2],fill_color)
#
#		# iterate over all faces and fill as defined
#		var faces = fill.get('faces',[])
#		for face_fill in faces:
#			var face = FACE_TYPE_LUT[face_fill['face']]
#			var fill_color = Color(face_fill['color'])
#			_set_cube_face_fill(cube[0],cube[1],cube[2],face,fill_color)

static func _make_key(x,y,z):
	return [int(x),int(y),int(z)]
	
func _get_cube_origin(i,j,k):
	return Vector3(int(i),int(j),int(k)) * CUBE_WIDTH

func _add_cube(x,y,z):
	var key = _make_key(x,y,z)
	if _cubes_by_xyz.has(key):
		vr.log_warning("duplicate add of cube meash at x,y,z = %s" % [key])
		return null
	
	var new_cube := BaseCubeScene.instance()
	new_cube.transform = Transform(Basis(), _get_cube_origin(x,y,z))
	new_cube.key = key
	$cubes.add_child(new_cube)
	_cubes_by_xyz[key] = new_cube
	return new_cube

# resize the collision shape based on the current width, height, and depth
func _update_grab_shape():
	var dims = [0,0,0]
	if puzzle:
		dims = puzzle.dims()
	grab_shape.shape.extents.x = dims[0] * CUBE_WIDTH / 2.0
	grab_shape.shape.extents.y = dims[1] * CUBE_WIDTH / 2.0
	grab_shape.shape.extents.z = dims[2] * CUBE_WIDTH / 2.0
	
	# place colision shape in middle of picross
	var half_cube_width = CUBE_WIDTH / 2.0
	grab_shape.transform.origin.x = dims[0] * CUBE_WIDTH / 2.0 - half_cube_width
	grab_shape.transform.origin.y = dims[1] * CUBE_WIDTH / 2.0 - half_cube_width
	grab_shape.transform.origin.z = dims[2] * CUBE_WIDTH / 2.0 - half_cube_width
	
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
	
func _cull_hidden_nodes():
	var dims = puzzle.dims()
	for cube in $cubes.get_children():
		if not cube.visible:
			continue
		var key = cube.key.duplicate()
		
		if cube is BaseCube:
			if cube.key[0] == 0:
				cube.show_face('left')
			elif _cubes_by_xyz[[key[0]-1,key[1],key[2]]].visible:
				cube.hide_face('left')
			else:
				cube.show_face('left')
			if cube.key[0] == dims[0] - 1:
				cube.show_face('right')
			elif _cubes_by_xyz[[key[0]+1,key[1],key[2]]].visible:
				cube.hide_face('right')
			else:
				cube.show_face('right')
				
			if cube.key[1] == 0:
				cube.show_face('bottom')
			elif _cubes_by_xyz[[key[0],key[1]-1,key[2]]].visible:
				cube.hide_face('bottom')
			else:
				cube.show_face('bottom')
			if cube.key[1] == dims[1] - 1:
				cube.show_face('top')
			elif _cubes_by_xyz[[key[0],key[1]+1,key[2]]].visible:
				cube.hide_face('top')
			else:
				cube.show_face('top')
				
			if cube.key[2] == 0:
				cube.show_face('front')
			elif _cubes_by_xyz[[key[0],key[1],key[2]-1]].visible:
				cube.hide_face('front')
			else:
				cube.show_face('front')
			if cube.key[2] == dims[2] - 1:
				cube.show_face('back')
			elif _cubes_by_xyz[[key[0],key[1],key[2]+1]].visible:
				cube.hide_face('back')
			else:
				cube.show_face('back')
	
func _process(_delta):
	if no_gravity:
		gravity_scale = 0
	else:
		gravity_scale = 1
