extends Spatial

func _ready():
	$BaseCube.set_unsolved()

func _process(delta):
	$BaseCube.transform = $BaseCube.transform.rotated(Vector3(1,0,0), 2 * PI / 16 * delta)
	$BaseCube.transform = $BaseCube.transform.rotated(Vector3(0,1,0), 2 * PI / 32 * delta)
	$BaseCube.transform.orthonormalized()
