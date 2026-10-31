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
	transition_Screen.visible = false
