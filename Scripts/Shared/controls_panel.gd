extends Control

# Read-only controls reference. Shown inside the reusable Settings panel.
signal closed

@onready var back_button: Button = $Shade/Center/Panel/Margins/VBox/BackButton


func _ready() -> void:
	# Works in both the main menu and paused gameplay.
	process_mode = Node.PROCESS_MODE_ALWAYS
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
