extends Spatial

var cubes = []

func _ready():
	$GreenCube.set_unsolved()
	$GreenCube.set_highlight_color(Color.green)
	cubes.append($GreenCube)
	$RedCube.set_unsolved()
	$RedCube.set_highlight_color(Color.red)
	cubes.append($RedCube)

func _process(delta):
	for cube in cubes:
		cube.transform = cube.transform.rotated(Vector3(1,0,0), 2 * PI / 16 * delta)
		cube.transform = cube.transform.rotated(Vector3(0,1,0), 2 * PI / 32 * delta)
		cube.transform.orthonormalized()
