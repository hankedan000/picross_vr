extends Picross
class_name EditablePicross

onready var next_cube := $NextPlaceCube
var _next_i = 0
var _next_j = 0
var _next_k = 0

func _ready():
	# we need at least 1 cube to build off of
	var cube = _add_cube(0,0,0)
	cube.state = BaseCube.State.Unsolved
	
	hide_next_cube()
	
func hide_next_cube():
	next_cube.hide()

func add_next_cube():
	if is_next_cube_valid():
		var cube = _add_cube(_next_i,_next_j,_next_k)
		cube.state = BaseCube.State.Unsolved
		hide_next_cube()

func set_next_cube_location(i,j,k):
	_next_i = i
	_next_j = j
	_next_k = k
	next_cube.transform.origin = _get_cube_origin(i,j,k)
	next_cube.show()
	
func is_next_cube_valid():
	return next_cube.visible
