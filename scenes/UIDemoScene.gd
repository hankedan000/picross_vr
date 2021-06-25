extends Spatial

onready var picross := $Picross

func _ready():
	game.active_picross = picross
	picross.from_file("res://assets/puzzles/heart1.json")
	picross.load_unsolved_shape()
