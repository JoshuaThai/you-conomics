extends Control

# One reusable Settings scene for both main menu and shared pause menu.
signal closed

const CONTROLS_PANEL_SCENE: PackedScene = preload("res://Scenes/UI/controls_panel.tscn")

@onready var fullscreen_toggle: CheckButton = $Shade/Center/Panel/Contents/VBox/FullscreenRow/FullscreenToggle
@onready var volume_slider: HSlider = $Shade/Center/Panel/Contents/VBox/VolumeRow/VolumeSlider
@onready var volume_value: Label = $Shade/Center/Panel/Contents/VBox/VolumeRow/VolumeValue
@onready var back_button: Button = $Shade/Center/Panel/Contents/VBox/BackButton

var controls_button: Button
var controls_panel: Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)
	volume_slider.value_changed.connect(_on_volume_changed)
	back_button.pressed.connect(close_panel)
	
	var settings_vbox: VBoxContainer = back_button.get_parent() as VBoxContainer
	controls_button = back_button.duplicate(0) as Button
	controls_button.name = "ControlsButton"
	controls_button.text = "CONTROLS"
	settings_vbox.add_child(controls_button)
	settings_vbox.move_child(controls_button, settings_vbox.get_node("Gap").get_index())
	controls_button.pressed.connect(_on_controls_pressed)
	
	# Controls has its own page, inside this same Settings instance.
	controls_panel = CONTROLS_PANEL_SCENE.instantiate() as Control
	add_child(controls_panel)
	controls_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	controls_panel.connect("closed", _on_controls_closed)
	controls_panel.hide()
	
	# The controls page's Back button inherits the user's actual styling.
	var controls_back: Button = controls_panel.get_node(
		"Shade/Center/Panel/Margins/VBox/BackButton"
	) as Button
	for style_name in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]:
		controls_back.add_theme_stylebox_override(
			style_name, back_button.get_theme_stylebox(style_name)
		)
	for color_name in [
		"font_color", "font_hover_color", "font_pressed_color",
		"font_focus_color", "font_disabled_color"
	]:
		controls_back.add_theme_color_override(
			color_name, back_button.get_theme_color(color_name)
		)
	controls_back.add_theme_font_size_override(
		"font_size", back_button.get_theme_font_size("font_size")
	)


func open_panel() -> void:
	# Always start on Settings, even if another menu hid us directly.
	controls_panel.hide()
	$Shade.show()
	
	var settings: Node = get_node("/root/GameSettings")
	fullscreen_toggle.set_pressed_no_signal(bool(settings.get("fullscreen")))
	var volume_percent: float = float(settings.get("master_volume")) * 100.0
	volume_slider.set_value_no_signal(volume_percent)
	volume_value.text = "%d%%" % roundi(volume_percent)
	show()
	back_button.grab_focus()


func close_panel() -> void:
	if not visible:
		return
	
	# ESC from Controls goes BACK to Settings instead of closing both.
	if controls_panel.visible:
		controls_panel.call("close_panel")
		return
	
	hide()
	closed.emit()


func _on_controls_pressed() -> void:
	$Shade.hide()
	controls_panel.call("open_panel")


func _on_controls_closed() -> void:
	$Shade.show()
	if visible:
		controls_button.grab_focus()


func _on_fullscreen_toggled(enabled: bool) -> void:
	get_node("/root/GameSettings").call("set_fullscreen", enabled)


func _on_volume_changed(percent: float) -> void:
	volume_value.text = "%d%%" % roundi(percent)
	get_node("/root/GameSettings").call("set_master_volume", percent / 100.0)
