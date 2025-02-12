extends Node

var config = ConfigFile.new()
const SETTINGS_FILE_PATH = "res://settings.ini"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		config.set_value("key", "forward", "W")
		config.set_value("key", "left", "A")
		config.set_value("key", "back", "S")
		config.set_value("key", "right", "D")
		config.set_value("key", "perspective", "`")
		config.set_value("key", "interact", "E")
		config.set_value("key", "sprint", "SHIFT")
		config.set_value("key", "ui_cancel", "ESC")
		
		config.set_value("video", "fullscreen", false)
		config.set_value("video", "subtitles", false)
		
		config.set_value("audio", "master_volume", 1.0)
		config.set_value("audio", "sfx_volume", 1.0)
		config.set_value("audio", "dialogue_volume", 1.0)
		
		config.save(SETTINGS_FILE_PATH)
	else:
		config.load(SETTINGS_FILE_PATH)
	
	
func save_video_settings(key: String, value):
	config.set_value("video", key, value)
	config.save(SETTINGS_FILE_PATH)
	
func save_audio_setting(key: String, value):
	config.set_value("audio", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_video_settings():
	var video_settings = {}
	for key in config.get_section_keys("video"):
		video_settings[key] = config.get_value("video", key)
	return video_settings

func load_audio_settings():
	var audio_settings = {}
	for key in config.get_section_keys("audio"):
		audio_settings[key] = config.get_value("audio", key)
		
