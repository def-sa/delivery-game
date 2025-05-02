extends Node3D

@onready var world: WorldEnvironment = $World/Environment/WorldEnvironment
@onready var pause_menu: Control = $CanvasLayer/pause_menu
@onready var requires_restart: ColorRect = $CanvasLayer/pause_menu/requires_restart


func _ready() -> void:
	DebugMenu.style = 2
	Signalbus.brightness_updated.connect(_brightness_updated)
	Signalbus.contrast_updated.connect(_contrast_updated)
	Signalbus.saturation_updated.connect(_saturation_updated)
	Signalbus.window_display_type_updated.connect(_window_display_type_updated)
	Signalbus.max_fps_updated.connect(_max_fps_updated)
	Signalbus.vsync_mode_updated.connect(_vsync_mode_updated)
	Signalbus.shadow_quality_updated.connect(_shadow_quality_updated)
	Signalbus.viewport_width_updated.connect(_viewport_width_updated)
	Signalbus.viewport_height_updated.connect(_viewport_height_updated)
	Signalbus.occlusion_culling_updated.connect(_occlusion_culling_updated)
	Signalbus.texture_filter_updated.connect(_texture_filter_updated)
	Signalbus.reflections_updated.connect(_reflections_updated)
	Signalbus.bilinear_filtering_updated.connect(_bilinear_filtering_updated)
	Signalbus.screen_space_reflections_updated.connect(_screen_space_reflections_updated)
	Signalbus.screen_space_ambient_occlusion_updated.connect(_screen_space_ambient_occlusion_updated)
	Signalbus.screen_space_indirect_lighting_updated.connect(_screen_space_indirect_lighting_updated)
	Signalbus.sdfgi_updated.connect(_sdfgi_updated)
	#Signalbus.is_paused.connect(_is_paused)
	

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
	var is_below_soft_low = bool(index <= 2)
	var default_size = get_window().get_viewport().positional_shadow_atlas_size*2
	
	RenderingServer.positional_soft_shadow_filter_set_quality(index)
	RenderingServer.directional_soft_shadow_filter_set_quality(index)
	var new_size = default_size
	if index == 0:
		new_size = 0
	else:
		new_size = default_size * index/3
	
	if is_below_soft_low:
		get_window().get_viewport().set_positional_shadow_atlas_16_bits(is_below_soft_low)
		ProjectSettings.set("rendering/lights_and_shadows/directional_shadow/16_bits", is_below_soft_low)
		for i in range(0,3):
			RenderingServer.viewport_set_positional_shadow_atlas_quadrant_subdivision(get_window().get_viewport(),i,0)
	
	RenderingServer.viewport_set_positional_shadow_atlas_size(get_window().get_viewport(),new_size)
	ProjectSettings.save()

var screen_size = DisplayServer.screen_get_size()
var popup_triggered = null
var previous_value = null

func _viewport_width_updated(value:int):
	if !popup_triggered:
		popup_triggered = pause_menu.revert_changes_popup(value, previous_value, Settings.viewport_width_name.replace(" ","_"))
		previous_value = null
	else:
		if value >= screen_size.x:
			value = screen_size.x
		DisplayServer.window_set_size(Vector2i(value, DisplayServer.window_get_size().y))
		previous_value = value
		popup_triggered = null

func _viewport_height_updated(value:int):
	if !popup_triggered:
		popup_triggered = pause_menu.revert_changes_popup(value, previous_value, Settings.viewport_height_name.replace(" ","_"))
		previous_value = null
	else:
		if value >= screen_size.y:
			value = screen_size.y
		DisplayServer.window_set_size(Vector2i(DisplayServer.window_get_size().x, value))

#func _is_paused(value:bool):


#TODO: doesnt need the popup, but keep for testing 
func _occlusion_culling_updated(value:String):
	if !popup_triggered:
		popup_triggered = pause_menu.revert_changes_popup(value, previous_value, Settings.occlusion_culling_name.replace(" ","_"))
		previous_value = null
	else:
		var index = Settings.occlusion_culling_selections.find(value)
		RenderingServer.viewport_set_occlusion_culling_build_quality(index)
		previous_value = value
		popup_triggered = null

func _texture_filter_updated(value: String):
	var index = Settings.texture_filter_selections.find(value)
	get_viewport().set_default_canvas_item_texture_filter(index)


func _reflections_updated(value: String):
	match value:
		"lowest":
			pass
		"low":
			pass
		"default":
			pass
		"high":
			pass
		"ultra":
			pass

##TODO: fix
func _bilinear_filtering_updated(value: bool):
	pause_menu.remove_from_restart_list(Settings.bilinear_filtering_name)
	pause_menu.add_to_restart_list(Settings.bilinear_filtering_name)
	ProjectSettings.set("rendering/textures/default_filters/use_nearest_mipmap_filter", value)
	

func _screen_space_reflections_updated(value: bool):
	world.environment.ssr_enabled = value

func _screen_space_ambient_occlusion_updated(value: bool):
	world.environment.ssao_enabled = value

func _screen_space_indirect_lighting_updated(value: bool):
	world.environment.ssil_enabled = value
	
func _sdfgi_updated(value: bool):
	world.environment.sdfgi_enabled = value

	#"lowest",
	#"low",
	#"default",
	#"high",
	#"ultra"
