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
	var prev_mode = selection_mode
	selection_mode = value
	if prev_mode != selection_mode:
		emit_signal("selection_mode_changed",selection_mode)

# the controller that we can select cubes from currently
func _get_selection_controller() -> ARVRController:
	# TODO handle transition from left to right hand
	return vr.rightController

const KEEP_BUTTON_IDS = [vr.BUTTON.A,vr.BUTTON.X]
const REMOVE_BUTTON_IDS = [vr.BUTTON.B,vr.BUTTON.Y]
func _process(_delta):
	var selection_controller := _get_selection_controller()
	if selection_controller:
		for button in KEEP_BUTTON_IDS:
			if selection_controller.is_button_pressed(button):
				self.selection_mode = SelectionMode.Keep
				break
		for button in REMOVE_BUTTON_IDS:
			if selection_controller.is_button_pressed(button):
				self.selection_mode = SelectionMode.Remove
				break
