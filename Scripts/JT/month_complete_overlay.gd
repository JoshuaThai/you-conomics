extends ColorRect


func _on_recap_continue_button_pressed():
	%MonthRecapOverlay.visible = false
	%MonthCompleteOverlay.visible = true


func _on_play_again_button_pressed():
	DayManager.reset_calendar()
	get_tree().reload_current_scene()


func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
