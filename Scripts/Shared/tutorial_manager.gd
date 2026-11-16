extends Node

# Keep these indices stable for scripts that read period_index.
const Dialogues = [
	"Welcome to the tutorial! I am You-bo and I am going to show you how to play You-conomics.", 
	"In You-conomics, you will be able to follow the stories of various characters like Steve here!", 
	"Your goal is to ensure they spend responsibly and go through 30 days in the life without being in debt!", 
	"To the top right of the screen, you have the character's stats.",
	"Ensure mood, energy, and money remains high to prevent unexpected consequences.",
	"Every day will usually consist of three periods: Morning, Afternoon, and Evening.",
	"Occassionally, you may have a night period.",
	"Most periods will have you answering different scenarios. Some periods will have none!",
	"Try answering the one below right now!",
	"There are no correct answers in this game. What matters is that you make the decision that best fits your character's conditions.",
	"Keep going!",
	"You can also move around by clicking. Try it!",
	"You can now go to next period! Click 'To Afternoon'.",
	"Be careful about unexpected bills as this could leave your character with debt.",
	"Keep playing and go the next period!",
	"Sometimes, you will have to interact with objects in the house to get to next period.",
	"Find the computer!",
	"For emails, you will need to decide whether to report it or respond. Be careful or you could lose money from making the wrong decision!",
	"That concludes the tutorial. I wish you luck, my friend!",
	"Click 'To Morning' to end the tutorial!"
	]

var inTutorial: bool = false
var noObjectInteraction = true
var emailTutorial = false
var dialogue_index: int = 0

func next_dialogue():
	if dialogue_index == len(Dialogues) - 1: 
		noObjectInteraction = true
		return ""
	dialogue_index += 1
	return Dialogues[dialogue_index]

# Determine if tutorial screen should be hidden or not.
func hide_tutorial_screen():
	if (dialogue_index == 1):
		return true
	else:
		return false
	
func reset():
	dialogue_index = 0
	noObjectInteraction = true
	
