extends Control

@onready var steve_manager = %SteveManager

# Show the current period's event dialogue
func _show_current_period_dialogue():
	var current_period = DayManager.get_period()
	print(current_period)
#	Play Breakfast event if morning
# Note: We will grab the breakfast info from steve_profile
# Look at how freddie did it in his script.
	if current_period == "Morning":
		var name = steve_manager.steve_profile["name"]
