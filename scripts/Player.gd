extends Node
class_name Player

signal selection_mode_changed(selection_mode)

enum SelectionMode {
	Keep,Remove
}

const KEEP_COLOR := Color.lightgreen
const REMOVE_COLOR := Color.coral

var selection_mode = SelectionMode.Keep setget _set_selection_mode

func _set_selection_mode(value):
	selection_mode = value
	emit_signal("selection_mode_changed",selection_mode)
