extends Control

@onready var steve_manager = %SteveManager
@onready var steve = %Steve



# Show the current period's event dialogue
func _show_current_period_dialogue():
	var current_period = DayManager.get_period()
	print(current_period)
#	Play Breakfast event if morning
# Note: We will grab the breakfast info from steve_profile
# Look at how freddie did it in his script.
	if current_period == "Morning":
		var eventData = EventManager.create_shared_event("breakfast", 
		steve_manager.steve_profile )
		print(eventData)
		var speaker = steve_manager.steve_profile["name"]
		var message = eventData["message"]
		
		var option1 = eventData["choices"][0]["text"]
		var option2 = eventData["choices"][1]["text"]
		var option3 = eventData["choices"][2]["text"]
		steve.available_choices_info = eventData["choices"]
		
		steve.show_dialogue(speaker, message, [option1, option2, option3] )
