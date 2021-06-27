extends Spatial

onready var picross := $Picross

func _ready():
	game.active_picross = picross
	var puzzle_json = vr.load_json_file("res://assets/puzzles/platypus.json")
	var puzzle = PicrossPuzzleUtils.fromJSON(puzzle_json)
	picross.load_unsolved_shape(puzzle)
	
