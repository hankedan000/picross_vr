extends ReferenceRect
class_name MainMenu

func _on_PlayButton_pressed():
	game.mode = game.GameMode.Play

func _on_CreateButton_pressed():
	game.mode = game.GameMode.Create
