extends Node3D

@onready var world: WorldEnvironment = $World/WorldEnvironment


func _ready() -> void:
	Signalbus.brightness_updated.connect(_brightness_updated)
	Signalbus.contrast_updated.connect(_contrast_updated)
	Signalbus.saturation_updated.connect(_saturation_updated)

func _brightness_updated(value):
	world.environment.adjustment_brightness = value

func _contrast_updated(value):
	world.environment.adjustment_contrast = value

func _saturation_updated(value):
	world.environment.adjustment_saturation = value
	
