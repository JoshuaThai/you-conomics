class_name DialogueManager
extends Panel

#region Node References

@onready var name_label: Label = $ContentMargin/VBox/NameLabel
@onready var dialogue_label: RichTextLabel = $ContentMargin/VBox/DialogueLabel
@onready var voice_blip: AudioStreamPlayer = $VoiceBlip

@onready var choice_buttons: Array[Button] = [
	$ContentMargin/VBox/Choices/Choice1Button,
	$ContentMargin/VBox/Choices/Choice2Button,
	$ContentMargin/VBox/Choices/Choice3Button
]

#endregion

#region Voice and Typewriter Settings

# Assign the downloaded .ogg files in the Inspector.
@export var fry_voice: AudioStream
@export var dulce_voice: AudioStream
@export var steve_voice: AudioStream
@export var default_voice: AudioStream

# Fine-tune pitch independently for each speaking character.
@export_range(0.5, 2.0, 0.05) var fry_pitch: float = 0.92
@export_range(0.5, 2.0, 0.05) var dulce_pitch: float = 1.15
@export_range(0.5, 2.0, 0.05) var steve_pitch: float = 1.03

@export_range(0.01, 0.15, 0.005) var character_delay: float = 0.035
@export_range(0.0, 0.5, 0.01) var punctuation_pause: float = 0.10
@export_range(1, 6, 1) var characters_per_blip: int = 2
@export_range(-40.0, 0.0, 1.0) var blip_volume_db: float = -12.0

# Per-character personality settings. These only affect dialogue blips;
# the underlying Fry events and choice buttons remain unchanged.
@export_group("Fry Voice Style")
@export_range(0.015, 0.10, 0.005) var fry_character_delay: float = 0.040
@export_range(1, 6, 1) var fry_characters_per_blip: int = 3
@export_range(-40.0, 0.0, 1.0) var fry_blip_volume_db: float = -13.0

@export_group("Dulce Voice Style")
@export_range(0.015, 0.10, 0.005) var dulce_character_delay: float = 0.045
@export_range(1, 6, 1) var dulce_characters_per_blip: int = 2
@export_range(-40.0, 0.0, 1.0) var dulce_blip_volume_db: float = -17.0

@export_group("Steve Voice Style")
@export_range(0.015, 0.10, 0.005) var steve_character_delay: float = 0.030
@export_range(1, 6, 1) var steve_characters_per_blip: int = 2
@export_range(-40.0, 0.0, 1.0) var steve_blip_volume_db: float = -11.0

# Optional per-line emotions do not modify a character's saved Inspector voice.
# Set to 0 to disable emotion effects, or 1 for the full preset.
@export_group("Emotion Settings")
@export_range(0.0, 1.0, 0.05) var emotion_strength: float = 1.0

var typing_id: int = 0
var is_typing: bool = false
var pending_options: Array = []
var current_voice_pitch: float = 1.0
var current_character_delay: float = 0.035
var current_characters_per_blip: int = 2
var current_punctuation_multiplier: float = 1.0
var current_pitch_jitter_min: float = 0.95
var current_pitch_jitter_max: float = 1.07
var current_emotion: String = "neutral"

#endregion

#region Signals

signal choice_selected(index: int)
signal speaker_changed(speaker: String)
signal dialogue_closed

#endregion

#region Initialization

func _ready() -> void:
	for i in range(choice_buttons.size()):
		choice_buttons[i].pressed.connect(_on_choice_pressed.bind(i))

	# RichTextLabel lets selected words wobble, wave or change color.
	# The rest of the dialogue uses the same typewriter system.
	dialogue_label.bbcode_enabled = true
	dialogue_label.scroll_active = false
	dialogue_label.fit_content = true
	dialogue_label.clip_contents = false
	dialogue_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Ensure voice blips freeze when the game is paused.
	voice_blip.process_mode = Node.PROCESS_MODE_PAUSABLE
	
	voice_blip.volume_db = blip_volume_db
	hide()

#endregion

#region Dialogue Display

# The fourth parameter is OPTIONAL; all existing three-argument calls still work.
# Supported: neutral, excited, nervous, soft, dramatic, tired, sad, angry.
func show_dialogue(
		speaker: String,
		message: String,
		options: Array,
		emotion: String = "neutral"
	) -> void:
	# Invalidate any older typewriter coroutine before changing the line.
	typing_id += 1
	var this_line_id: int = typing_id
	is_typing = true
	pending_options = options.duplicate()

	name_label.text = speaker
	dialogue_label.text = message
	dialogue_label.visible_characters = 0

	# Choices only appear once the line is finished or skipped.
	for button in choice_buttons:
		button.hide()

	_set_voice_for_speaker(speaker)
	_apply_emotion(emotion)
	show()
	speaker_changed.emit(speaker)

	_type_dialogue(dialogue_label.get_parsed_text(), this_line_id)


func _set_voice_for_speaker(speaker: String) -> void:
	voice_blip.stop()
	current_voice_pitch = 1.0
	current_character_delay = character_delay
	current_characters_per_blip = characters_per_blip
	voice_blip.volume_db = blip_volume_db

	match speaker.strip_edges().to_upper():
		"FRY":
			voice_blip.stream = fry_voice
			current_voice_pitch = fry_pitch
			current_character_delay = fry_character_delay
			current_characters_per_blip = fry_characters_per_blip
			voice_blip.volume_db = fry_blip_volume_db
		"DULCE":
			voice_blip.stream = dulce_voice
			current_voice_pitch = dulce_pitch
			current_character_delay = dulce_character_delay
			current_characters_per_blip = dulce_characters_per_blip
			voice_blip.volume_db = dulce_blip_volume_db
		"STEVE":
			voice_blip.stream = steve_voice
			current_voice_pitch = steve_pitch
			current_character_delay = steve_character_delay
			current_characters_per_blip = steve_characters_per_blip
			voice_blip.volume_db = steve_blip_volume_db
		"YOU-BO":
			# Reuse Fry's blip with a higher-pitched, robotic personality.
			voice_blip.stream = fry_voice if fry_voice != null else default_voice
			current_voice_pitch = 1.45
			current_character_delay = 0.028
			current_characters_per_blip = 2
			voice_blip.volume_db = -15.0

		_:
			voice_blip.stream = default_voice



func _apply_emotion(emotion: String) -> void:
	# _set_voice_for_speaker() has already reset the base voice profile,
	# so emotion effects cannot accidentally carry over to the next line.
	current_emotion = emotion.strip_edges().to_lower()
	current_punctuation_multiplier = 1.0
	current_pitch_jitter_min = 0.95
	current_pitch_jitter_max = 1.07

	var profile: Dictionary = {}
	match current_emotion:
		"excited", "happy":
			profile = {"pitch": 1.15, "speed": 0.78, "volume": 2.0, "blips": -1, "pause": 0.85}
		"nervous", "shy":
			profile = {"pitch": 1.08, "speed": 0.89, "volume": -1.0, "blips": 0, "pause": 1.1}
		"soft", "gentle":
			profile = {"pitch": 0.96, "speed": 1.08, "volume": -5.0, "blips": 1, "pause": 1.0}
		"dramatic":
			profile = {"pitch": 0.88, "speed": 1.20, "volume": 2.0, "blips": -1, "pause": 1.35}
		"tired":
			profile = {"pitch": 0.83, "speed": 1.30, "volume": -3.0, "blips": 1, "pause": 1.25}
		"sad":
			profile = {"pitch": 0.91, "speed": 1.18, "volume": -2.0, "blips": 1, "pause": 1.2}
		"angry":
			profile = {"pitch": 1.02, "speed": 0.88, "volume": 3.0, "blips": -1, "pause": 0.75}
		_:
			# Neutral or an unknown emotion: preserve the existing voice exactly.
			current_emotion = "neutral"
			return

	# Soften Dulce and Steve when they're excited.
	# Leave Fry's excited voice unchanged.
	if current_emotion in ["excited", "happy"]:
		if name_label.text.strip_edges().to_upper() in ["DULCE", "STEVE"]:
			profile["volume"] = -3.0

	var strength: float = clampf(emotion_strength, 0.0, 1.0)
	current_voice_pitch *= lerpf(1.0, float(profile["pitch"]), strength)
	current_character_delay *= lerpf(1.0, float(profile["speed"]), strength)
	voice_blip.volume_db = clampf(
		voice_blip.volume_db + float(profile["volume"]) * strength,
		-40.0,
		0.0
	)

	# Only change blip frequency once the effect is strong enough to be audible.
	if strength >= 0.5:
		current_characters_per_blip = maxi(
			1,
			current_characters_per_blip + int(profile["blips"])
		)

	current_punctuation_multiplier = lerpf(
		1.0,
		float(profile["pause"]),
		strength
	)

	# Nervous lines wobble more than other emotions.
	if current_emotion in ["nervous", "shy"]:
		current_pitch_jitter_min = lerpf(0.95, 0.88, strength)
		current_pitch_jitter_max = lerpf(1.07, 1.13, strength)


func _type_dialogue(message: String, this_line_id: int) -> void:
	var audible_character_count: int = 0

	for i in range(message.length()):
		if this_line_id != typing_id or not is_typing:
			return

		var character: String = message.substr(i, 1)
		dialogue_label.visible_characters = i + 1

		# Ignore spaces and punctuation when counting blips.
		if character.strip_edges() != "" and character not in [
			".", ",", "!", "?", ":", ";", "-", "—", "…"
		]:
			audible_character_count += 1

			if (
				voice_blip.stream != null
				and audible_character_count % maxi(1, current_characters_per_blip) == 0
			):
				voice_blip.pitch_scale = current_voice_pitch * randf_range(
					current_pitch_jitter_min,
					current_pitch_jitter_max
				)
				voice_blip.play()

		var delay: float = current_character_delay
		if character in [".", "!", "?", "…"]:
			delay += punctuation_pause * current_punctuation_multiplier
		elif character in [",", ";", ":"]:
			delay += punctuation_pause * 0.5 * current_punctuation_multiplier

		await get_tree().create_timer(delay, false).timeout

	if this_line_id == typing_id and is_typing:
		_finish_typing()


func _finish_typing() -> void:
	if not is_typing:
		return

	# Cancel outstanding timer callbacks from this line.
	typing_id += 1
	is_typing = false
	dialogue_label.visible_characters = -1
	voice_blip.stop()

	for i in range(choice_buttons.size()):
		var button: Button = choice_buttons[i]

		if i < pending_options.size():
			button.text = str(pending_options[i])
			button.show()
		else:
			button.hide()


func close_dialogue() -> void:
	typing_id += 1
	is_typing = false
	voice_blip.stop()
	hide()
	dialogue_closed.emit()

#endregion

#region Skip Typing

func _input(event: InputEvent) -> void:
	if not visible or not is_typing:
		return

	var should_skip: bool = false

	# A click inside the dialogue panel reveals the whole line.
	if event is InputEventMouseButton:
		should_skip = (
			event.pressed
			and event.button_index == MOUSE_BUTTON_LEFT
			and get_global_rect().has_point(get_global_mouse_position())
		)

	# Space/Enter also reveal the line, without selecting a choice.
	elif event.is_action_pressed("ui_accept"):
		should_skip = true

	if should_skip:
		_finish_typing()
		get_viewport().set_input_as_handled()

#endregion

#region Choice Handling

func _on_choice_pressed(index: int) -> void:
	# Safety: never submit an option while a line is animating.
	if is_typing:
		_finish_typing()
		return

	choice_selected.emit(index)

#endregion
