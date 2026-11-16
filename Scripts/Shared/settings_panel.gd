extends Control

# One reusable Settings scene for both main menu and shared pause menu.
signal closed

@onready var fullscreen_toggle: CheckButton = $Shade/Center/Panel/Contents/VBox/FullscreenRow/FullscreenToggle
@onready var volume_slider: HSlider = $Shade/Center/Panel/Contents/VBox/VolumeRow/VolumeSlider
@onready var volume_value: Label = $Shade/Center/Panel/Contents/VBox/VolumeRow/VolumeValue
@onready var back_button: Button = $Shade/Center/Panel/Contents/VBox/BackButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)
	volume_slider.value_changed.connect(_on_volume_changed)
	back_button.pressed.connect(close_panel)


func open_panel() -> void:
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
	hide()
	closed.emit()


func _on_fullscreen_toggled(enabled: bool) -> void:
	get_node("/root/GameSettings").call("set_fullscreen", enabled)


func _on_volume_changed(percent: float) -> void:
	volume_value.text = "%d%%" % roundi(percent)
	get_node("/root/GameSettings").call("set_master_volume", percent / 100.0)
