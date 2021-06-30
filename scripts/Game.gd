extends Node

signal game_mode_changed(game_mode)

enum GameMode {
	Play,Create
}

var active_picross : Picross = null
var active_room : BaseRoom = null
var mode = GameMode.Play setget _set_game_mode

func _set_game_mode(value):
	var prev_mode = mode
	mode = value
	if prev_mode != mode:
		emit_signal("game_mode_changed",mode)
