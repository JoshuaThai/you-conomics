extends Control

@onready var transition_Screen = %TransitionScreen
@onready var steve = %Steve
@onready var kitchen_spawn = %KitchenSpawn
@onready var room_spawn = %RoomSpawn

#func _process(delta):
	#print("Debounce: ", steve.debounce)
	
func _on_door_button_pressed():
	print("Home Steve ID: ", steve.get_instance_id(), " debounce: ", steve.debounce)
	if steve.debounce: return
	print("BUTTON WAS PRESSED!")
	var tween = get_tree().create_tween()
	steve.pause_movement()
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
	steve.unpause_movement()
	
func _trigger_transition_on_start():
	print("Transition Triggered")
	transition_Screen.visible = true
	transition_Screen.modulate.a = 1.0
	var tween = get_tree().create_tween()
	tween.tween_property(transition_Screen, "modulate:a", 0.0, 2.0)
	await tween.finished
	transition_Screen.visible = false
	return true

func _spawn_in_room():
	steve.position = room_spawn.position
	var tween = get_tree().create_tween()
	tween.tween_property(transition_Screen, "modulate:a", 0.0, 3.0)
	await tween.finished
	transition_Screen.visible = false
	steve.unpause_movement()

func _on_back_to_room_button_pressed():
#	Player cannot click back to room if the player isn't supposed to be moving
	if steve.debounce: return
	#print(steve.debounce)
	steve.pause_movement()
	var tween = get_tree().create_tween()
	transition_Screen.visible = true
	tween.tween_property(transition_Screen, "modulate:a", 1.0, 3.0)
	await tween.finished
	_spawn_in_room()
	

func _on_calendar_button_pressed():
	steve.open_panel("Calendar")


func _on_computer_button_pressed():
	steve.open_panel("Computer")


func _on_fridge_button_pressed():
	steve.open_panel("Fridge")


func _on_mail_button_pressed():
	steve.open_panel("HouseDoor")
