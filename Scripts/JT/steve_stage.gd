class_name SteveStage
extends Node


# Randomly generate load in the character's info
func _ready():
#	Load the player's data for the first day
	%SteveEventHandler.randomize_event()
	%SteveEventHandler._show_current_period_dialogue()
