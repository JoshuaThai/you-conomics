
class_name SteveDialogueManager
extends Panel

#region Node References
# Joshua, make sure to add your own node references for your dialogue stuff.

@onready var name_label: Label = $ContentMargin/VBox/NameLabel
@onready var dialogue_label: Label = %DialogueLabel

@onready var money_label: Label = %MoneyLabel
@onready var mood_label: Label = %MoodLabel
@onready var energy_label: Label = %EnergyLabel

@onready var choice_buttons: Array[Button] = [
	%Choice1Button,
	%Choice2Button,
	%Choice3Button
]

var player_choices: Array[String] = []

#endregion


#region Signals

signal choice_selected(index: int)

#endregion


#region Initialization

func _ready() -> void:
	for i in range(choice_buttons.size()):
		choice_buttons[i].pressed.connect(
			_on_choice_pressed.bind(i)
		)

	hide()

#endregion

# Will be used to regularly update mood, money, and energy
func _process(delta):
	money_label.text = "$" + str(owner.money)
	mood_label.text = "Mood: " + str(owner.mood)
	energy_label.text = "Energy: " + str(owner.energy)
	#print("Owner Debounce: ", owner.debounce)


#region Dialogue Display

func show_dialogue(speaker: String,message: String, options: Array) -> void:
	player_choices.clear()
	#%NextPeriodButton.hide()
	%TaskLabel.hide()
	%PhoneUI.hide()
	name_label.text = speaker
	dialogue_label.text = message

	for i in range(choice_buttons.size()):
		var button := choice_buttons[i]

		if i < options.size():
#			Hide choice if grocery meals number is too low
			if (options[i].contains("Make breakfast")
			or (owner.currentEvent == "Lunch" 
			and options[i].contains("Prepare Lunch Yourself"))
			or (owner.currentEvent == "Get a Drink"
			and options[i].contains("Yes"))
			or (owner.currentEvent == "Dinner"
			and options[i].contains("Prepare Dinner Yourself"))
			or (owner.currentEvent == "Snack" 
			and options[i].contains("Prepare a Snack"))):
				if owner.grocery_meals <= 0:
					button.hide()
					continue
			button.text = str(options[i])
			player_choices.append(options[i])
			button.show()
		else:
			button.hide()

	show()


func close_dialogue() -> void:
	hide()

#endregion


#region Choice Handling

func _on_choice_pressed(index: int) -> void:
	choice_selected.emit(index)

#endregion

# BIG QUESTION: How to keep track of current event and its info

func _on_choice_1_button_pressed():
	var choiceSelected = choice_buttons[0].text
	check_if_correct_response(choiceSelected)
			
#	Use the info to modify mood/energy/money as needed.
	

func _on_choice_2_button_pressed():
	var choiceSelected = choice_buttons[1].text
	check_if_correct_response(choiceSelected)


func _on_choice_3_button_pressed():
	var choiceSelected = choice_buttons[2].text
	check_if_correct_response(choiceSelected)
	
	
func display_other_UI():
	#%NextPeriodButton.show()
	%TaskLabel.show()
	%PhoneUI.show()
	

func check_if_correct_response(choiceSelected: String):
	if (choiceSelected.contains("Make breakfast")
	or (owner.currentEvent == "Lunch" 
	and choiceSelected.contains("Prepare Lunch Yourself"))
	or (owner.currentEvent == "Get a Drink"
	and choiceSelected.contains("Yes"))
	or (owner.currentEvent == "Dinner"
	and choiceSelected.contains("Prepare Dinner Yourself"))
	or (owner.currentEvent == "Snack" 
	and choiceSelected.contains("Prepare a Snack"))):
		owner.grocery_meals -= 1
		owner.load_necessary_data("Fridge", {})
	#print(owner.available_choices_info)
	for choice in owner.available_choices_info:
		#print(choice["text"])
#		If the choice selected is a match, show reaction
# 		and modify money, money, and energy
		if choiceSelected == choice["text"]:
			hide_choices()
			if choice.has("reaction"):
				dialogue_label.text = choice["reaction"]
				await get_tree().create_timer(3.0).timeout
			#owner.money += choice["money"]
			owner.mood += choice["mood"]
			if choice.has("energy"):
				owner.energy += choice["energy"]
			close_dialogue()
			var money = choice["money"]
#			Fix bug where money would be added from purchasing wishlist sale item
			if owner.currentEvent == "wishlist_sale":
				money *= -1
			owner.change_money(money, owner.currentEvent)
			owner.unpause_movement()
			
			display_other_UI()
#			Play the scene where I hang out with friends before ending dialogue
			if owner.currentEvent == "Hanging out with friends":
				%WithFriends.visible = true
			owner.ongoingDialogue = false
			#print("Current Event: ", owner.currentEvent)
			if owner.currentEvent == "Nap" and choiceSelected == "Yes":
				owner.nappingOrSleep = true
				owner.afternoonEvents.clear()
				owner._on_next_period_button_pressed()
			if (owner.currentEvent == "Sleep" 
			and choiceSelected == "Yes"):
				owner.nappingOrSleep = true
				owner.eveningEvents.clear()
				owner._on_next_period_button_pressed()
			
			#print("Owner Debounce: ", owner.debounce)
			
			#show_response()
## This function will hide all choices
func hide_choices():
	for choice in choice_buttons:
		choice.hide()
