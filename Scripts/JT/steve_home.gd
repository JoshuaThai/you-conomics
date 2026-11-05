extends Control

@onready var transition_Screen = %TransitionScreen
@onready var steve = %Steve
@onready var kitchen_spawn = %KitchenSpawn

func _on_door_button_pressed():
	var tween = get_tree().create_tween()
	transition_Screen.visible = true
	tween.tween_property(transition_Screen, "modulate:a", 1.0, 3.0)
	await tween.finished
	_spawn_in_kitchen()
	
		
func _spawn_in_kitchen():
	steve.position = kitchen_spawn.position
	var tween = get_tree().create_tween()
	tween.tween_property(transition_Screen, "modulate:a", 0.0, 3.0)
	await tween.finished
	transition_Screen.visible = false
	
func _trigger_transition_on_start():
	print("Transition Triggered")
	transition_Screen.visible = true
	transition_Screen.modulate.a = 1.0
	var tween = get_tree().create_tween()
	tween.tween_property(transition_Screen, "modulate:a", 0.0, 2.0)
	await tween.finished
	transition_Screen.visible = false
	return true
