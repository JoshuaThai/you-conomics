extends CanvasLayer

# You-bo's loading messages.
const YOU_BO_LOADING_MESSAGES = [
	"There are no save points in this game. Good luck.",
	"Loading walking animations... Just kidding.",
	"Resetting your debt. Don't get used to it.",
	"Fun fact: Fry has more financial problems than animations.",
	"Your choices matter. No pressure or anything.",
	"Please wait. You-bo is doing something incredibly important.",
	"Loading financial responsibility... 404 Not Found.",
	"Don't worry. I know what I'm doing. Probably.",
	"Remember: Spending money is easy. Having money is the hard part."
]

const FRY_STORY_SCENE: String = "res://Scenes/fry_home.tscn"
const YOU_BO_IMAGE: Texture2D = preload("res://Images/Bob.png")

@export_range(0.05, 3.0, 0.05) var fade_out_seconds: float = 0.45
@export_range(0.05, 3.0, 0.05) var fade_in_seconds: float = 0.55

var _fade_rect: ColorRect
var _is_transitioning: bool = false

var _youbo_loading_row: HBoxContainer
var _youbo_loading_icon: TextureRect
var _youbo_loading_label: Label
var _youbo_spinning: bool = false


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS

	_fade_rect = ColorRect.new()
	_fade_rect.name = "FadeToBlack"
	_fade_rect.color = Color("#0A0E17")
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.modulate.a = 0.0
	_fade_rect.visible = false
	add_child(_fade_rect)
	_fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_youbo_loading_ui()


func _process(delta: float) -> void:
	if not _youbo_spinning:
		return
	
	if _youbo_loading_icon == null:
		return
	
	# Rotate around the center of You-bo's image.
	_youbo_loading_icon.pivot_offset = _youbo_loading_icon.size * 0.5
	
	# Positive rotation is clockwise in Godot's screen coordinates.
	_youbo_loading_icon.rotation += delta * 3.5


func fade_to_scene(scene_path: String) -> void:
	if _is_transitioning:
		return
	if not ResourceLoader.exists(scene_path):
		push_error("Cannot transition: missing scene " + scene_path)
		return

	_is_transitioning = true
	_fade_rect.visible = true
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	_fade_rect.modulate.a = 0.0

	var fade_out: Tween = create_tween()
	fade_out.tween_property(
		_fade_rect, "modulate:a", 1.0, fade_out_seconds
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await fade_out.finished

	var result: int = get_tree().change_scene_to_file(scene_path)
	if result != OK:
		push_error("Scene change failed (%d): %s" % [result, scene_path])
		var recovery: Tween = create_tween()
		recovery.tween_property(_fade_rect, "modulate:a", 0.0, fade_in_seconds)
		await recovery.finished
		_finish_transition()
		return

	# SceneTree.scene_changed fires after the new scene is active.
	await get_tree().scene_changed
	await get_tree().process_frame

	var fade_in: Tween = create_tween()
	fade_in.tween_property(
		_fade_rect, "modulate:a", 0.0, fade_in_seconds
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await fade_in.finished
	_finish_transition()


func _finish_transition() -> void:
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.visible = false
	_is_transitioning = false


func _build_youbo_loading_ui() -> void:
	# Container anchored to the bottom-right corner.
	_youbo_loading_row = HBoxContainer.new()
	_youbo_loading_row.name = "YouBoLoadingRow"
	_youbo_loading_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_youbo_loading_row.add_theme_constant_override("separation", 16)
	
	_fade_rect.add_child(_youbo_loading_row)
	
	_youbo_loading_row.anchor_left = 1.0
	_youbo_loading_row.anchor_right = 1.0
	_youbo_loading_row.anchor_top = 1.0
	_youbo_loading_row.anchor_bottom = 1.0
	
	_youbo_loading_row.offset_left = -610
	_youbo_loading_row.offset_right = -36
	_youbo_loading_row.offset_top = -140
	_youbo_loading_row.offset_bottom = -36
	
	# You-bo's rotating image.
	_youbo_loading_icon = TextureRect.new()
	_youbo_loading_icon.name = "SpinningYouBo"
	_youbo_loading_icon.texture = YOU_BO_IMAGE
	_youbo_loading_icon.custom_minimum_size = Vector2(72, 72)
	_youbo_loading_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_youbo_loading_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_youbo_loading_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_youbo_loading_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	_youbo_loading_row.add_child(_youbo_loading_icon)
	
	# Random message beside You-bo.
	_youbo_loading_label = Label.new()
	_youbo_loading_label.name = "LoadingMessage"
	_youbo_loading_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_youbo_loading_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_youbo_loading_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	_youbo_loading_label.add_theme_font_size_override("font_size", 22)
	_youbo_loading_label.add_theme_color_override(
		"font_color",
		Color("#F0F0F0")
	)
	
	_youbo_loading_row.add_child(_youbo_loading_label)
	_youbo_loading_row.hide()


func fade_to_fry_story_with_youbo() -> void:
	if _is_transitioning:
		return
	
	if not ResourceLoader.exists(FRY_STORY_SCENE):
		push_error("Fry's story scene was not found.")
		return
	
	_is_transitioning = true
	
	
	var previous_color: Color = _fade_rect.color
	
	# Fade completely to black.
	_fade_rect.color = Color.BLACK
	_fade_rect.modulate.a = 0.0
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	_fade_rect.show()
	
	_youbo_loading_row.hide()
	_youbo_loading_icon.rotation = 0.0
	
	# Choose one of the nine messages.
	var message_index: int = randi_range(
		0,
		YOU_BO_LOADING_MESSAGES.size() - 1
	)
	
	_youbo_loading_label.text = YOU_BO_LOADING_MESSAGES[message_index]
	
	# Fade out the tutorial scene.
	var fade_out: Tween = create_tween()
	
	fade_out.tween_property(
		_fade_rect,
		"modulate:a",
		1.0,
		0.6
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	await fade_out.finished
	
	# Show spinning You-bo on the black screen.
	_youbo_loading_row.modulate.a = 0.0
	_youbo_loading_row.show()
	_youbo_spinning = true
	
	var appear: Tween = create_tween()
	appear.tween_property(
		_youbo_loading_row,
		"modulate:a",
		1.0,
		0.25
	)
	
	await appear.finished
	
	# Keep the loading message visible briefly.
	await get_tree().create_timer(1.8, true).timeout
	
	# Load a completely fresh instance of Fry's story.
	var result: int = get_tree().change_scene_to_file(
		FRY_STORY_SCENE
	)
	
	if result != OK:
		push_error("Could not load Fry's story.")
	
		_youbo_spinning = false
	
		var recovery: Tween = create_tween()
		recovery.tween_property(_fade_rect, "modulate:a", 0.0, 0.5)
		await recovery.finished
	
		_youbo_loading_row.hide()
		_fade_rect.color = previous_color
		_finish_transition()
		return
	
	# Wait for the new scene to finish initializing.
	await get_tree().scene_changed
	await get_tree().process_frame
	
	# Fade into Fry's fresh Day 1.
	var fade_in: Tween = create_tween()
	
	fade_in.tween_property(
		_fade_rect,
		"modulate:a",
		0.0,
		0.7
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	await fade_in.finished
	
	# Clean up the loading display.
	_youbo_spinning = false
	_youbo_loading_row.hide()
	_fade_rect.color = previous_color
	
	_finish_transition()
