extends BasicRoom

func _ready():
	picross().load_from_json_file("res://assets/puzzles/platypus.json")
	picross().load_unsolved_shape()
