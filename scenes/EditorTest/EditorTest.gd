extends Spatial

func _ready():
	game.mode = game.GameMode.Create
	game.active_picross = $EditablePicross

func _input(event):
	if event is InputEventMouse:
		$CubeRaycast.rotation_degrees.x = event.position.x / 1000.0 * 360
