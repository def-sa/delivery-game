extends Node3D

@onready var world: WorldEnvironment = $World/Environment/WorldEnvironment
@onready var pause_menu: Control = $CanvasLayer/pause_menu


func _ready() -> void:
	Signalbus.brightness_updated.connect(_brightness_updated)
	Signalbus.contrast_updated.connect(_contrast_updated)
	Signalbus.saturation_updated.connect(_saturation_updated)
	Signalbus.window_display_type_updated.connect(_window_display_type_updated)
	Signalbus.max_fps_updated.connect(_max_fps_updated)
	Signalbus.vsync_mode_updated.connect(_vsync_mode_updated)
	Signalbus.shadow_quality_updated.connect(_shadow_quality_updated)
	Signalbus.viewport_width_updated.connect(_viewport_width_updated)
	Signalbus.viewport_height_updated.connect(_viewport_height_updated)
	Signalbus.is_paused.connect(_is_paused)
	

func _brightness_updated(value:float):
	world.environment.adjustment_brightness = value

func _contrast_updated(value:float):
	world.environment.adjustment_contrast = value

func _saturation_updated(value:float):
	world.environment.adjustment_saturation = value
	
func _window_display_type_updated(value:String):
	var index = Settings.window_display_type_selections.find(value)
	DisplayServer.window_set_mode(index)
	
func _vsync_mode_updated(value:String):
	var index = Settings.vsync_mode_selections.find(value)
	DisplayServer.window_set_vsync_mode(index)

func _max_fps_updated(value:int):
	Engine.max_fps = value

func _shadow_quality_updated(value:String):
	var index = Settings.shadow_quality_selections.find(value)
	ProjectSettings.set_setting("rendering/lights_and_shadows/positional_shadow/soft_shadow_filter_quality", index)
	ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality", index)
	
var buffered_width = null
func _viewport_width_updated(value:int):
	buffered_width = value

var buffered_height
func _viewport_height_updated(value:int):
	buffered_height = value

func _is_paused(value:bool):
	var screen_size = DisplayServer.screen_get_size()
	if !value and buffered_width:
		if buffered_width >= screen_size.x:
			buffered_width = screen_size.x
		DisplayServer.window_set_size(Vector2i(buffered_width, DisplayServer.window_get_size().y))
	if !value and buffered_height:
		if buffered_height >= screen_size.y:
			buffered_height = screen_size.y
		DisplayServer.window_set_size(Vector2i(DisplayServer.window_get_size().x, buffered_height))
