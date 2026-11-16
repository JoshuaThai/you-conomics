extends Control

# Main-menu credits overlay. Reuses the menu's visual style.
signal closed

@onready var back_button: Button = $Center/Panel/Margins/Contents/BackButton


func _ready() -> void:
	hide()
	back_button.pressed.connect(close_panel)


func open_panel() -> void:
	show()
	back_button.grab_focus()


func close_panel() -> void:
	if not visible:
		return
	hide()
	closed.emit()
