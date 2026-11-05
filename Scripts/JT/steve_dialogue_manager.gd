
class_name SteveDialogueManager
extends Panel

#region Node References
# Joshua, make sure to add your own node references for your dialogue stuff.

@onready var name_label: Label = $ContentMargin/VBox/NameLabel
@onready var dialogue_label: Label = $ContentMargin/VBox/DialogueLabel

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


#region Dialogue Display

func show_dialogue(speaker: String,message: String, options: Array) -> void:
	player_choices.clear()
	name_label.text = speaker
	dialogue_label.text = message

	for i in range(choice_buttons.size()):
		var button := choice_buttons[i]

		if i < options.size():
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
	print(owner.available_choices_info)
#	Use the info to modify mood/energy/money as needed.
	

func _on_choice_2_button_pressed():
	var choiceSelected = choice_buttons[1].text


func _on_choice_3_button_pressed():
	var choiceSelected = choice_buttons[2].text
