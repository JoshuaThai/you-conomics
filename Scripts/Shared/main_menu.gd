extends Control

const FRY_SCENE: String = "res://Scenes/fry_home.tscn"
const STEVE_SCENE: String = "res://Scenes/steve_stage.tscn"

const SETTINGS_PANEL_SCENE: PackedScene = preload(
	"res://Scenes/UI/settings_panel.tscn"
)

var settings_panel: Control

@onready var main_page: Control = $MainPage
@onready var story_page: Control = $StoryPage
@onready var tutorial_page: Control = $TutorialPage

@onready var play_button: Button = $MainPage/MainCenter/MainVBox/PlayButton
@onready var settings_button: Button = $MainPage/MainCenter/MainVBox/SettingsButton
@onready var tutorial_button: Button = $MainPage/MainCenter/MainVBox/TutorialButton
@onready var credits_button: Button = $MainPage/MainCenter/MainVBox/CreditsButton

@onready var fry_button: Button = $StoryPage/StoryCenter/StoryVBox/CharacterCards/FryButton
@onready var steve_button: Button = $StoryPage/StoryCenter/StoryVBox/CharacterCards/SteveButton
@onready var back_button: Button = $StoryPage/StoryCenter/StoryVBox/BackButton

@onready var tutorial_fry_button: Button = $TutorialPage/StoryCenter/StoryVBox/CharacterCards/FryButton
@onready var tutorial_steve_button: Button = $TutorialPage/StoryCenter/StoryVBox/CharacterCards/SteveButton
@onready var tutorial_back_button: Button = $TutorialPage/StoryCenter/StoryVBox/BackButton


func _ready() -> void:
	TutorialManager.inTutorial = false
	
	main_page.show()
	story_page.hide()
	tutorial_page.hide()
	
	# Main menu
	play_button.pressed.connect(_on_play_pressed)
	tutorial_button.pressed.connect(_on_tutorial_pressed)
	
	# Story selection
	back_button.pressed.connect(_on_back_pressed)
	fry_button.pressed.connect(_on_fry_pressed)
	steve_button.pressed.connect(_on_steve_pressed)
	
	# Tutorial selection
	tutorial_back_button.pressed.connect(_on_tutorial_back_pressed)
	tutorial_fry_button.pressed.connect(_on_tutorial_fry_pressed)
	tutorial_steve_button.pressed.connect(_on_tutorial_steve_pressed)
	
	# Settings and credits are not implemented yet.
	settings_button.disabled = true
	credits_button.disabled = true
	tutorial_button.disabled = false
	
	settings_button.tooltip_text = "Coming soon"
	credits_button.tooltip_text = "Coming soon"
	tutorial_button.tooltip_text = ""
	
	play_button.grab_focus()
	
	# Create the shared settings screen.
	settings_panel = SETTINGS_PANEL_SCENE.instantiate()
	add_child(settings_panel)
	settings_panel.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	settings_panel.connect("closed", _on_settings_closed)
	
	settings_button.disabled = false
	settings_button.tooltip_text = ""
	settings_button.pressed.connect(_on_settings_pressed)



func _on_play_pressed() -> void:
	main_page.hide()
	story_page.show()
	fry_button.grab_focus()


func _on_back_pressed() -> void:
	story_page.hide()
	main_page.show()
	play_button.grab_focus()


func _on_tutorial_pressed() -> void:
	main_page.hide()
	story_page.hide()
	tutorial_page.show()
	tutorial_fry_button.grab_focus()


func _on_tutorial_back_pressed() -> void:
	tutorial_page.hide()
	main_page.show()
	tutorial_button.grab_focus()


func _on_tutorial_fry_pressed() -> void:
	_open_tutorial(FRY_SCENE)


func _on_tutorial_steve_pressed() -> void:
	_open_tutorial(STEVE_SCENE)


func _on_fry_pressed() -> void:
	_open_story(FRY_SCENE)


func _on_steve_pressed() -> void:
	_open_story(STEVE_SCENE)


func _open_story(scene_path: String) -> void:
	if not ResourceLoader.exists(scene_path):
		push_error("Story scene not found: " + scene_path)
		return

	# Normal PLAY must never activate tutorial mode.
	TutorialManager.inTutorial = false
	TutorialManager.reset()

	get_node("/root/SceneTransition").fade_to_scene(scene_path)


func _open_tutorial(scene_path: String) -> void:
	if not ResourceLoader.exists(scene_path):
		push_error("Tutorial scene not found: " + scene_path)
		return

	# Begin a fresh tutorial session.
	TutorialManager.reset()
	TutorialManager.inTutorial = true

	get_node("/root/SceneTransition").fade_to_scene(scene_path)


func _unhandled_key_input(event: InputEvent) -> void:
	if settings_panel != null and settings_panel.visible:
		if event.is_action_pressed("ui_cancel"):
			settings_panel.call("close_panel")
			get_viewport().set_input_as_handled()
		return
	
	if not event.is_action_pressed("ui_cancel"):
		return
	
	if story_page.visible:
		_on_back_pressed()
		get_viewport().set_input_as_handled()
	
	elif tutorial_page.visible:
		_on_tutorial_back_pressed()
		get_viewport().set_input_as_handled()


func _on_settings_pressed() -> void:
	main_page.hide()
	settings_panel.call("open_panel")


func _on_settings_closed() -> void:
	main_page.show()
	settings_button.grab_focus()
