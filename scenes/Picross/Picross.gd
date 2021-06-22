extends Spatial
class_name Picross

# a copy of the BaseCube node that all copies will be instanced from
var base_cube : Spatial = null

# FIXME make this dynamic it doesn't change with the origina size of the BaseCube.mesh
const CUBE_WIDTH = 0.02

# absolute bounds of the 
var _width = 0
var _height = 0
var _depth = 0

var _data = {
	"name" : "",
	"shape" : [],
	"hint_groups" : [],
	"fill" : []
}

func _ready():
	# store a copy of the base cube for reinstancing later
	base_cube = $BaseCube.duplicate()
	remove_child($BaseCube)

func from_file(filepath : String):
	vr.log_info("Loading picross from file %s" % filepath)
	var data = vr.load_json_file(filepath)
	
	reset()
	for cube in data['shape']:
		add_cube(cube[0],cube[1],cube[2])

func reset():
	_clear_all_cubes()
	_data = {
		"name" : "",
		"shape" : [],
		"hint_groups" : [],
		"fill" : []
	}
		
	_width = 0
	_height = 0
	_depth = 0
		
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
				_add_cube_mesh(x,y,z)
	
func load_solved_shape():
	_clear_all_cubes()
	
	# load the final shape
	for cube in _data.shape:
		_add_cube_mesh(cube[0],cube[1],cube[2])
	
func _add_cube_mesh(x,y,z):
	var new_cube : Spatial = base_cube.duplicate()
	var origin = Vector3(int(x),int(y),int(z)) * CUBE_WIDTH
	new_cube.transform = Transform(Basis(), origin)
	$cubes.add_child(new_cube)
	
func _clear_all_cubes():
	for cube in $cubes.get_children():
		cube.queue_free()
