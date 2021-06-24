extends Spatial

onready var picross = $Picross

func _ready():
	picross.from_file("res://assets/puzzles/heart1.json")
	picross.load_unsolved_shape()
	
func _process(delta):
	picross.rotate(Vector3(1,0,0),2 * PI / 15.0 * delta)
	picross.rotate(Vector3(0,1,0),2 * PI / 20.0 * delta)
