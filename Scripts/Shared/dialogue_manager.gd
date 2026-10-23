
class_name DialogueManager
extends Panel

#region Node References
# Joshua, make sure to add your own node references for your dialogue stuff.

@onready var name_label: Label = $ContentMargin/VBox/NameLabel
@onready var dialogue_label: Label = $ContentMargin/VBox/DialogueLabel

@onready var choice_buttons: Array[Button] = [
	$ContentMargin/VBox/Choices/Choice1Button,
	$ContentMargin/VBox/Choices/Choice2Button,
	$ContentMargin/VBox/Choices/Choice3Button
]

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

	name_label.text = speaker
	dialogue_label.text = message

	for i in range(choice_buttons.size()):
		var button := choice_buttons[i]

		if i < options.size():
			button.text = str(options[i])
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
