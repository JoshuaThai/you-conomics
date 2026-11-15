extends Control



const FRY_SCENE: String = "res://Scenes/fry_home.tscn"
const STEVE_SCENE: String = "res://Scenes/steve_stage.tscn"

@onready var main_page: Control = $MainPage
@onready var story_page: Control = $StoryPage

@onready var play_button: Button = $MainPage/MainCenter/MainVBox/PlayButton
@onready var settings_button: Button = $MainPage/MainCenter/MainVBox/SettingsButton
@onready var tutorial_button: Button = $MainPage/MainCenter/MainVBox/TutorialButton
@onready var credits_button: Button = $MainPage/MainCenter/MainVBox/CreditsButton

@onready var fry_button: Button = $StoryPage/StoryCenter/StoryVBox/CharacterCards/FryButton
@onready var steve_button: Button = $StoryPage/StoryCenter/StoryVBox/CharacterCards/SteveButton
@onready var back_button: Button = $StoryPage/StoryCenter/StoryVBox/BackButton


func _ready() -> void:
	main_page.show()
	story_page.hide()

	play_button.pressed.connect(_on_play_pressed)
	back_button.pressed.connect(_on_back_pressed)
	fry_button.pressed.connect(_on_fry_pressed)
	steve_button.pressed.connect(_on_steve_pressed)

	# Visible placeholders. They do not navigate anywhere yet.
	settings_button.disabled = true
	tutorial_button.disabled = true
	credits_button.disabled = true
	settings_button.tooltip_text = "Coming soon"
	tutorial_button.tooltip_text = "Coming soon"
	credits_button.tooltip_text = "Coming soon"

	play_button.grab_focus()


func _on_play_pressed() -> void:
	main_page.hide()
	story_page.show()
	fry_button.grab_focus()


func _on_back_pressed() -> void:
	story_page.hide()
	main_page.show()
	play_button.grab_focus()


func _on_fry_pressed() -> void:
	_open_story(FRY_SCENE)


func _on_steve_pressed() -> void:
	_open_story(STEVE_SCENE)


func _open_story(scene_path: String) -> void:
	if not ResourceLoader.exists(scene_path):
		push_error("Story scene not found: " + scene_path)
		return

	# The transition is an Autoload so the fade survives scene replacement.
	get_node("/root/SceneTransition").fade_to_scene(scene_path)


func _unhandled_key_input(event: InputEvent) -> void:
	# Esc takes the player from story selection back to the main menu.
	if story_page.visible and event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
		get_viewport().set_input_as_handled()
