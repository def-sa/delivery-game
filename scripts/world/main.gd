extends Node3D

@onready var world: WorldEnvironment = $World/Environment/WorldEnvironment


func _ready() -> void:
	Signalbus.brightness_updated.connect(_brightness_updated)
	Signalbus.contrast_updated.connect(_contrast_updated)
	Signalbus.saturation_updated.connect(_saturation_updated)
	Signalbus.window_display_type_updated.connect(_window_display_type_updated)

func _brightness_updated(value:float):
	world.environment.adjustment_brightness = value

func _contrast_updated(value:float):
	world.environment.adjustment_contrast = value

func _saturation_updated(value:float):
	world.environment.adjustment_saturation = value
	
func _window_display_type_updated(value:String):
	match value:
		"windowed":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		"fullscreen":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		"borderless_fullscreen":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
