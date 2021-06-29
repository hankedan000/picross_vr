extends Spatial
class_name BaseRoom
	
func is_ui_visible() -> bool:
	return false

func show_main_menu():
	pass
	
func hide_main_menu():
	pass

func main_menu() -> MainMenu:
	return null

func picross() -> Picross:
	return null
