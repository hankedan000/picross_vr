extends Spatial

onready var picross := $Picross

func _ready():
	picross.from_file("res://assets/puzzles/heart1.json")
	picross.load_unsolved_shape()

var show_unsolved = false
func _on_Timer_timeout():
	if show_unsolved:
		picross.load_unsolved_shape()
	else:
		picross.load_solved_shape()
	show_unsolved = not show_unsolved
