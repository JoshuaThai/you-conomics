extends CanvasLayer

# Do NOT attach this script to either character's gameplay scene!!

const FRY_SCENE: String = "res://Scenes/fry_home.tscn"
const STEVE_SCENE: String = "res://Scenes/steve_stage.tscn"
const MAIN_MENU_SCENE: String = "res://Scenes/main_menu.tscn"

@onready var pause_root: Control = $PauseRoot
@onready var resume_button: Button = $PauseRoot/Center/Panel/Contents/ResumeButton
@onready var settings_button: Button = $PauseRoot/Center/Panel/Contents/SettingsButton
@onready var main_menu_button: Button = $PauseRoot/Center/Panel/Contents/MainMenuButton
@onready var quit_button: Button = $PauseRoot/Center/Panel/Contents/QuitButton

@onready var confirm_root: Control = $PauseRoot/ConfirmationRoot
@onready var confirm_label: Label = $PauseRoot/ConfirmationRoot/Center/Panel/Contents/Question
@onready var confirm_yes_button: Button = $PauseRoot/ConfirmationRoot/Center/Panel/Contents/ConfirmButtons/YesButton
@onready var confirm_cancel_button: Button = $PauseRoot/ConfirmationRoot/Center/Panel/Contents/ConfirmButtons/CancelButton

var _paused_by_us: bool = false
var _navigation_busy: bool = false
var _pending_action: String = ""


func _ready() -> void:
	# This autoload must receive ESC and button clicks while the game is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 80  # Below SceneTransition (layer 100).
	pause_root.hide()
	confirm_root.hide()

	resume_button.pressed.connect(_resume_game)
	main_menu_button.pressed.connect(_ask_to_return_to_menu)
	quit_button.pressed.connect(_ask_to_quit)
	confirm_yes_button.pressed.connect(_confirm_action)
	confirm_cancel_button.pressed.connect(_cancel_confirmation)

	settings_button.disabled = true
	settings_button.tooltip_text = "Coming soon"

	# If a game scene changes for some other reason, never leave the next scene paused.
	get_tree().scene_changed.connect(_on_scene_changed)


func _input(event: InputEvent) -> void:
	if _navigation_busy:
		return
	if event is InputEventKey and event.echo:
		return
	if not event.is_action_pressed("ui_cancel"):
		return

	if not _paused_by_us and not _is_gameplay_scene():
		return
	
	get_viewport().set_input_as_handled()
	
	if confirm_root.visible:
		_cancel_confirmation()
	elif _paused_by_us:
		_resume_game()
	else:
		_pause_game()


func _is_gameplay_scene() -> bool:
	var current: Node = get_tree().current_scene
	if current == null:
		return false
	var path: String = current.scene_file_path
	return path == FRY_SCENE or path == STEVE_SCENE


func _pause_game() -> void:
	if _paused_by_us or get_tree().paused:
		return
	_paused_by_us = true
	_pending_action = ""
	confirm_root.hide()
	pause_root.show()
	get_tree().paused = true
	resume_button.grab_focus()


func _resume_game() -> void:
	if _navigation_busy:
		return
	_clear_pause_state()


func _clear_pause_state() -> void:
	_paused_by_us = false
	_pending_action = ""
	_navigation_busy = false
	confirm_root.hide()
	pause_root.hide()
	get_tree().paused = false


func _ask_to_return_to_menu() -> void:
	_pending_action = "main_menu"
	confirm_label.text = "Return to the main menu?\nYour current run will be lost."
	confirm_root.show()
	confirm_cancel_button.grab_focus()


func _ask_to_quit() -> void:
	_pending_action = "quit"
	confirm_label.text = "Quit You-conomics?\nYour current run will be lost."
	confirm_root.show()
	confirm_cancel_button.grab_focus()


func _cancel_confirmation() -> void:
	var was_returning_to_menu: bool = _pending_action == "main_menu"
	_pending_action = ""
	confirm_root.hide()
	if was_returning_to_menu:
		main_menu_button.grab_focus()
	else:
		quit_button.grab_focus()


func _confirm_action() -> void:
	if _navigation_busy:
		return
	
	if _pending_action == "quit":
		get_tree().paused = false
		get_tree().quit()
		return
	
	if _pending_action != "main_menu":
		_cancel_confirmation()
		return
	
	if not ResourceLoader.exists(MAIN_MENU_SCENE):
		push_error("PauseMenu: Missing main menu scene: " + MAIN_MENU_SCENE)
		_cancel_confirmation()
		return
	
	_navigation_busy = true
	confirm_root.hide()
	
	var transition: Node = get_node_or_null("/root/SceneTransition")
	if transition != null and transition.has_method("fade_to_scene"):
		transition.fade_to_scene(MAIN_MENU_SCENE)
		await get_tree().scene_changed
		_clear_pause_state()
	else:
		# Fallback in case the fade autoload was not installed.
		_clear_pause_state()
		var error: int = get_tree().change_scene_to_file(MAIN_MENU_SCENE)
		if error != OK:
			push_error("PauseMenu: Unable to load main menu. Code: %d" % error)


func _on_scene_changed() -> void:
	if _paused_by_us and not _navigation_busy:
		_clear_pause_state()
