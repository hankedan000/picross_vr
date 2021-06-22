extends Spatial

# a copy of the BaseCube node that all copies will be instanced from
var base_cube : Spatial = null

# FIXME make this dynamic it doesn't change with the origina size of the BaseCube.mesh
const CUBE_WIDTH = 0.02

func _ready():
	# store a copy of the base cube for reinstancing later
	base_cube = $BaseCube.duplicate()
	remove_child($BaseCube)

func clear():
	for cube in $cubes.get_children():
		cube.queue_free()
		
func add_cube(x,y,z):
	var new_cube : Spatial = base_cube.duplicate()
	var origin = Vector3(int(x),int(y),int(z)) * CUBE_WIDTH
	new_cube.transform = Transform(Basis(), origin)
	$cubes.add_child(new_cube)

func _cube_width():
	return base_cube
