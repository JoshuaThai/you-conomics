extends CanvasLayer

# YOU-CONOMICS — Persistent fade transition
# Add as an Autoload named SceneTransition in Project Settings.

@export_range(0.05, 3.0, 0.05) var fade_out_seconds: float = 0.45
@export_range(0.05, 3.0, 0.05) var fade_in_seconds: float = 0.55

var _fade_rect: ColorRect
var _is_transitioning: bool = false


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
