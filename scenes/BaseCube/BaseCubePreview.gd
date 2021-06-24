extends Spatial

var cubes = []

func _ready():
	$GreenCube.state = BaseCube.State.Highlighted
	$GreenCube.highlight_color = Color.green
	$GreenCube.set_fb_label(2)
	cubes.append($GreenCube)
	$RedCube.state = BaseCube.State.Highlighted
	$RedCube.highlight_color = Color.red
	$RedCube.set_fb_label(4)
	cubes.append($RedCube)

func _process(delta):
	for cube in cubes:
		cube.transform = cube.transform.rotated(Vector3(1,0,0), 2 * PI / 16 * delta)
		cube.transform = cube.transform.rotated(Vector3(0,1,0), 2 * PI / 32 * delta)
		cube.transform.orthonormalized()
