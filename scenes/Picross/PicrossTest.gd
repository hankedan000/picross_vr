extends Spatial

onready var picross = $Picross

func _ready():
	var puzzle_json = vr.load_json_file("res://assets/puzzles/platypus.json")
	var puzzle = PicrossPuzzleUtils.fromJSON(puzzle_json)
	picross.load_unsolved_shape(puzzle)
	
func _process(delta):
	picross.rotate(Vector3(1,0,0),2 * PI / 15.0 * delta)
	picross.rotate(Vector3(0,1,0),2 * PI / 20.0 * delta)
