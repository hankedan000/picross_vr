extends BaseRoom
class_name BasicRoom

onready var picross : Picross = $Picross
onready var editable_picross : EditablePicross = $EditablePicross
onready var ui_raycast := $OQ_ARVROrigin/OQ_RightController/Feature_UIRayCast
onready var cube_raycast := $OQ_ARVROrigin/OQ_RightController/CubeRaycast

# height of the menu (from top of UI_Canvas) off the ground in meter
const MENU_HEIGHT = 1.0

# distance in meters away from player where menu will be spawned
const MENU_DISTANCE = 1.0

func _ready():
	game.active_room = self
	game.active_picross = picross()
	
	game.connect("game_mode_changed",self,"_on_game_mode_changed")
	
	show_main_menu()
	
func is_ui_visible() -> bool:
	if $MainMenuCanvas.visible:
		return true
	return false

func show_main_menu():
	if vr.vrCamera && vr.vrOrigin:
		var look_angle_y = vr.vrCamera.global_transform.basis.get_euler().y
		var menu_loc = Vector3(0,MENU_HEIGHT,-MENU_DISTANCE).rotated(Vector3(0,1,0),look_angle_y)
		var camera_loc = vr.vrCamera.global_transform.origin
		$MainMenuCanvas.global_transform.origin = menu_loc
		$MainMenuCanvas.global_transform = $MainMenuCanvas.global_transform.looking_at(camera_loc,Vector3.UP)
		$MainMenuCanvas.rotation_degrees.x = 0
		$MainMenuCanvas.rotation_degrees.z = 0
		
	$MainMenuCanvas.show()
	
func hide_main_menu():
	$MainMenuCanvas.hide()

func main_menu() -> MainMenu:
	return $MainMenuCanvas.ui_control
	
func picross() -> Picross:
	return picross
	
func editable_picross() -> EditablePicross:
	return editable_picross
	
func _process(delta):
	# toggle menu visibility when MENU button is pressed
	if vr.button_just_pressed(vr.BUTTON.ENTER):
		if $MainMenuCanvas.visible:
			hide_main_menu()
		else:
			show_main_menu()
		
	if is_ui_visible():
		ui_raycast.visible = true
		cube_raycast.visible = false
	else:
		ui_raycast.visible = false
		cube_raycast.visible = true
		
func _on_game_mode_changed(mode):
	if mode == game.GameMode.Play:
		picross.show()
		editable_picross.hide()
		game.active_picross = picross
	elif mode == game.GameMode.Create:
		picross.hide()
		editable_picross.show()
		game.active_picross = editable_picross
