class_name SteveStage
extends Node


# Randomly generate load in the character's info
func _ready():
	if TutorialManager.inTutorial:
		%SteveEventHandler.load_tutorial()
		%SteveEventHandler._show_current_period_dialogue()
	else:
	#	Load the player's data for the first day
		%SteveEventHandler.randomize_event()
		%SteveEventHandler._show_current_period_dialogue()
