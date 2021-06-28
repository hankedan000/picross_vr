extends Spatial

onready var picross := $Picross

func _ready():
	game.active_picross = picross
	picross.load_from_json_file("res://assets/puzzles/platypus.json")
	picross.load_unsolved_shape()
	
