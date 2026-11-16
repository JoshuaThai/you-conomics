extends ColorRect


func _on_tutorial_again_button_pressed():
	TutorialManager.reset()
	get_tree().reload_current_scene()


func _on_main_menu_button_2_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
