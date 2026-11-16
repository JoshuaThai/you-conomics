extends Node

const SAVE_PATH: String = "user://settings.cfg"

var fullscreen: bool = false
var master_volume: float = 1.0


func _ready() -> void:
	load_settings()
	apply_settings()


func load_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	var result: Error = config.load(SAVE_PATH)
	
	if result == OK:
		fullscreen = bool(config.get_value("display", "fullscreen", false))
		master_volume = clampf(float(config.get_value("audio", "master_volume", 1.0)), 0.0, 1.0)
	elif result != ERR_FILE_NOT_FOUND:
		push_warning("Could not read game settings. Using defaults. Error: %d" % result)


func save_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("display", "fullscreen", fullscreen)
	config.set_value("audio", "master_volume", master_volume)
	var result: Error = config.save(SAVE_PATH)
	if result != OK:
		push_warning("Could not save game settings. Error: %d" % result)


func apply_settings() -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen
		else DisplayServer.WINDOW_MODE_WINDOWED
	)
	_apply_master_volume()


func set_fullscreen(value: bool) -> void:
	fullscreen = value
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen
		else DisplayServer.WINDOW_MODE_WINDOWED
	)
	save_settings()


func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	_apply_master_volume()
	save_settings()


func _apply_master_volume() -> void:
	var master_bus: int = AudioServer.get_bus_index("Master")
	if master_bus < 0:
		push_warning("Audio bus 'Master' was not found.")
		return
	
	AudioServer.set_bus_mute(master_bus, master_volume <= 0.0)
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(maxf(master_volume, 0.001)))
