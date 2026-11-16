extends Control

var debounce = false

func _ready():
	%TutorialLabel.text = TutorialManager.Dialogues[0]

func _on_continue_tutorial_pressed():
	if debounce: return
		
	debounce = true
	var nextDialogue = TutorialManager.next_dialogue()
#	Empty next dialogue means end of tutorial!
	if (nextDialogue == "" 
	or %TutorialLabel.text == "Try answering the one below right now!"
	or %TutorialLabel.text == "Keep going!"
	or %TutorialLabel.text == "You can now go to next period! Click 'To Afternoon'."
	or nextDialogue == "Be careful about unexpected bills as this could leave your character with debt."
	or nextDialogue == "Sometimes, you will have to interact with objects in the house to get to next period."
	or nextDialogue ==  "Find the computer!"
	or nextDialogue == "For emails, you will need to decide whether to report it or respond. Be careful or you could lose money from making the wrong decision!"
	or %TutorialLabel.text == "For emails, you will need to decide whether to report it or respond. Be careful or you could lose money from making the wrong decision!"):
		print("Tutorial HUD should be hidden!")
		if nextDialogue == "For emails, you will need to decide whether to report it or respond. Be careful or you could lose money from making the wrong decision!":
			TutorialManager.noObjectInteraction = false
		%TutorialHUD.visible = false
	elif %TutorialLabel.text == "You can also move around by clicking. Try it!":
		%TutorialHUD.visible = false
		await get_tree().create_timer(5.0).timeout
		%TutorialHUD.visible = true
	elif nextDialogue == "To the top right of the screen, you have the character's stats.":
		%HighlightStats.visible = true
	#elif nextDialogue == "Click 'To Morning' to end the tutorial!":
		#%TutorialCompleteOverlay.visible = true
	else:
		%HighlightStats.visible = false
	%TutorialLabel.text = nextDialogue
	debounce = false
	
