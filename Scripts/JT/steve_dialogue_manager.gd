class_name SteveDialogueManager
extends "res://Scripts/Shared/dialogue_manager.gd"


#region Steve-specific Node References

# NameLabel, DialogueLabel (RichTextLabel), VoiceBlip and the three
# choice_buttons already come from the shared DialogueManager.
@onready var money_label: Label = %MoneyLabel
@onready var mood_label: Label = %MoodLabel
@onready var energy_label: Label = %EnergyLabel

var player_choices: Array[String] = []

#endregion

#region Initialization

func _ready() -> void:
	# This configures the typewriter, voice blips and the choice_selected
	# signal exactly as the original Steve manager did.
	super._ready()

	voice_blip.process_mode = Node.PROCESS_MODE_PAUSABLE


func _process(_delta: float) -> void:
	money_label.text = "$" + str(owner.money)
	mood_label.text = "Mood: " + str(owner.mood)
	energy_label.text = "Energy: " + str(owner.energy)

#endregion

#region Dialogue Display

# The fourth argument is optional, just like Fry's dialogue manager.
# Example: show_dialogue("STEVE", "[shake]WHAT?![/shake]", ["Continue"], "dramatic")
func show_dialogue(
		speaker: String,
		message: String,
		options: Array,
		emotion: String = "neutral"
	) -> void:
	%TaskLabel.hide()
	%PhoneUI.hide()

	player_choices.clear()
	for option in options:
		var option_text: String = str(option)
		if not _requires_unavailable_groceries(option_text):
			player_choices.append(option_text)

	super.show_dialogue(speaker, message, options, emotion)


func _finish_typing() -> void:
	super._finish_typing()
	for i in range(choice_buttons.size()):
		if i < pending_options.size():
			var option_text: String = str(pending_options[i])
			if _requires_unavailable_groceries(option_text):
				choice_buttons[i].hide()


func _requires_unavailable_groceries(option_text: String) -> bool:
	if int(owner.grocery_meals) > 0:
		return false

	var event_name: String = str(owner.currentEvent)
	return (
		option_text.contains("Make breakfast")
		or (event_name == "Lunch" and option_text.contains("Prepare Lunch Yourself"))
		or (event_name == "Get a Drink" and option_text.contains("Yes"))
		or (event_name == "Dinner" and option_text.contains("Prepare Dinner Yourself"))
		or (event_name == "Snack" and option_text.contains("Prepare a Snack"))
	)


func close_dialogue() -> void:
	# Cancels outstanding typewriter timers and stops the voice blips.
	super.close_dialogue()

#endregion

#region Steve-specific Choice Handling


# Do not remove those editor signal connections.
func _on_choice_1_button_pressed() -> void:
	check_if_correct_response(choice_buttons[0].text)


func _on_choice_2_button_pressed() -> void:
	check_if_correct_response(choice_buttons[1].text)


func _on_choice_3_button_pressed() -> void:
	check_if_correct_response(choice_buttons[2].text)


func display_other_UI() -> void:
	%TaskLabel.show()
	%PhoneUI.show()


func hide_choices() -> void:
	for choice_button in choice_buttons:
		choice_button.hide()


func check_if_correct_response(choice_selected_text: String) -> void:
	
	if (
		choice_selected_text.contains("Make breakfast")
		or (owner.currentEvent == "Lunch" and choice_selected_text.contains("Prepare Lunch Yourself"))
		or (owner.currentEvent == "Get a Drink" and choice_selected_text.contains("Yes"))
		or (owner.currentEvent == "Dinner" and choice_selected_text.contains("Prepare Dinner Yourself"))
		or (owner.currentEvent == "Snack" and choice_selected_text.contains("Prepare a Snack"))
	):
		owner.grocery_meals -= 1
		owner.load_necessary_data("Fridge", {})

	for choice in owner.available_choices_info:
		if choice_selected_text != str(choice.get("text", "")):
			continue

		hide_choices()

		if choice.has("reaction") and str(choice["reaction"]) != "":
			var reaction_speaker: String = str(choice.get("reaction_speaker", name_label.text))
			var reaction_emotion: String = str(choice.get("reaction_emotion", "neutral"))
			show_dialogue(reaction_speaker, str(choice["reaction"]), [], reaction_emotion)

			while is_typing and is_inside_tree():
				await get_tree().process_frame
			if not is_inside_tree():
				return
			await get_tree().create_timer(0.85, false).timeout

		# Original effects, money changes and time progression are kept.
		owner.mood += choice["mood"]
		owner.mood = clamp(owner.mood, 0 , 100)
		if choice.has("energy"):
			owner.energy += choice["energy"]
			owner.energy = clamp(owner.energy, 0, 100)

		close_dialogue()
		var money = choice["money"]
		if owner.currentEvent == "wishlist_sale":
			money *= -1
		owner.change_money(money, owner.currentEvent)
		owner.unpause_movement()

		display_other_UI()
		print("Current Event: ", owner.currentEvent)
		owner.ongoingDialogue = false

		if owner.currentEvent == "Nap" and choice_selected_text == "Yes":
			owner.nappingOrSleep = true
			owner.afternoonEvents.clear()
			owner._on_next_period_button_pressed()

		if owner.currentEvent == "Sleep" and choice_selected_text == "Yes":
			owner.nappingOrSleep = true
			owner.eveningEvents.clear()
			owner._on_next_period_button_pressed()
		return

#endregion
