extends Node

@export_category("Display")
#region window display type dropdown
@export_group("window display type", "window_display_type")
@export var window_display_type_selections:Array[String] = [
	"windowed",
	"minimized",
	"maximized",
	"fullscreen", 
	"borderless_fullscreen"
	]
@export var window_display_type_default:String = window_display_type_selections[0]

var window_display_type:String = window_display_type_default:
	set(v):
		if window_display_type_selections.has(v):
			window_display_type = v
			Signalbus.window_display_type_updated.emit(window_display_type)
#endregion
#region vsync mode dropdown
@export_group("vsync mode", "vsync_mode")
@export var vsync_mode_selections:Array[String] = [
	"disabled",
	"enabled",
	"adaptive",
	"mailbox_(fast_vsync)"
	]
@export var vsync_mode_default:String = vsync_mode_selections[3]

var vsync_mode:String = vsync_mode_default:
	set(v):
		if vsync_mode_selections.has(v):
			vsync_mode = v
			Signalbus.vsync_mode_updated.emit(vsync_mode)
#endregion
#region shadow_quality dropdown
@export_group("shadow quality", "shadow_quality")
@export var shadow_quality_selections:Array[String] = [
	"hard_(fastest)",
	"soft_very_low_(faster)",
	"soft_low_(fast)",
	"soft_medium_(average)",
	"soft_high_(slow)",
	"soft_ultra_(slowest)"
	]
@export var shadow_quality_default:String = shadow_quality_selections[3]

var shadow_quality:String = shadow_quality_default:
	set(v):
		if shadow_quality_selections.has(v):
			shadow_quality = v
			Signalbus.shadow_quality_updated.emit(shadow_quality)
#endregion
#region fov slider
@export_group("fov", "fov")
@export var fov_min: int = 1
@export var fov_max: int = 179
@export var fov_default:int = 95
@export var fov_step: int = 1

var fov:int = fov_default:
	set(v):
		fov = clamp(v, fov_min, fov_max)
		Signalbus.fov_updated.emit(fov)
#endregion
#region show_fps toggle
@export_group("show fps", "show_fps")
@export var show_fps_default:bool = true
var show_fps:bool = show_fps_default:
	set(v):
		show_fps = v
		Signalbus.show_fps_updated.emit(show_fps)
#endregion
#region max_fps slider
@export_group("max fps", "max_fps")
@export var max_fps_min: int = 0
@export var max_fps_max: int = 512
@export var max_fps_default:int = 0
@export var max_fps_step: int = 1

var max_fps:float = max_fps_default:
	set(v):
		max_fps = clamp(v, max_fps_min, max_fps_max)
		Signalbus.max_fps_updated.emit(max_fps)
#endregion
#region viewport width slider
@export_group("viewport width", "viewport_width")
@export var viewport_width_min: int = 1
@export var viewport_width_max: int = 7680
@export var viewport_width_default:int = 1700
@export var viewport_width_step: int = 1

var viewport_width:float = viewport_width_default:
	set(v):
		viewport_width = clamp(v, viewport_width_min, viewport_width_max)
		Signalbus.viewport_width_updated.emit(viewport_width)
#endregion
#region viewport height slider
@export_group("viewport height", "viewport_height")
@export var viewport_height_min: int = 1
@export var viewport_height_max: int = 4320
@export var viewport_height_default:int = 900
@export var viewport_height_step: int = 1

var viewport_height:float = viewport_height_default:
	set(v):
		viewport_height = clamp(v, viewport_height_min, viewport_height_max)
		Signalbus.viewport_height_updated.emit(viewport_height)
#endregion


#region brightness slider
@export_group("brightness", "brightness")
@export var brightness_min: float = 0.001
@export var brightness_max: float = 8
@export var brightness_default:float = 1
@export var brightness_step: float = 0.01

var brightness:float = brightness_default:
	set(v):
		brightness = clamp(v, brightness_min, brightness_max)
		Signalbus.brightness_updated.emit(brightness)
#endregion
#region contrast slider
@export_group("contrast", "contrast")
@export var contrast_min: float = 0.001
@export var contrast_max: float = 8
@export var contrast_default:float = 1
@export var contrast_step: float = 0.01

var contrast:float = contrast_default:
	set(v):
		contrast = clamp(v, contrast_min, contrast_max)
		Signalbus.contrast_updated.emit(contrast)
#endregion
#region saturation slider
@export_group("saturation", "saturation")
@export var saturation_min: float = 0.001
@export var saturation_max: float = 8
@export var saturation_default:float = 1
@export var saturation_step: float = 0.01

var saturation:float = saturation_default:
	set(v):
		saturation = clamp(v, saturation_min, saturation_max)
		Signalbus.saturation_updated.emit(saturation)
#endregion




@export_category("Gameplay")
#region render distance slider
@export_group("render distance", "render_distance")
@export var render_distance_min: int = 2
@export var render_distance_max: int = 22
@export var render_distance_default:int = 6
@export var render_distance_step: int = 1

var render_distance:int = render_distance_default:
	set(v):
		render_distance = clamp(v, render_distance_min, render_distance_max)
		Signalbus.render_distance_updated.emit(render_distance)
#endregion

@export_category("Audio")
#region main volume slider
@export_group("main volume", "main_volume")
@export var main_volume_min: int = 0
@export var main_volume_max: int = 100
@export var main_volume_default:int = 50
@export var main_volume_step: int = 1

var main_volume:int = main_volume_default:
	set(v):
		main_volume = clamp(v, main_volume_min, main_volume_max)
		Signalbus.main_volume_updated.emit(main_volume)
#endregion

@export_category("Controls")
#region sensitivity slider
@export_group("sensitivity", "sensitivity")
@export var sensitivity_min: int = 1
@export var sensitivity_max: int = 100
@export var sensitivity_default:int = 44
@export var sensitivity_step: int = 1

var sensitivity:int = sensitivity_default:
	set(v):
		sensitivity = clamp(v, sensitivity_min, sensitivity_max)
		Signalbus.sensitivity_updated.emit(sensitivity)
#endregion

@export_category("Debug")
#region player speed slider
@export_group("player speed", "player_speed")
@export var player_speed_min: int = 1
@export var player_speed_max: int = 250
@export var player_speed_default:int = 12
@export var player_speed_step: int = 1

var player_speed:int = sensitivity_default:
	set(v):
		player_speed = clamp(v, player_speed_min, player_speed_max)
		Signalbus.player_speed_updated.emit(player_speed)
#endregion
#region player jump slider
@export_group("player jump", "player_jump")
@export var player_jump_min: float = 1
@export var player_jump_max: float = 250
@export var player_jump_default:float = 12
@export var player_jump_step: float = 1

var player_jump:float = player_jump_default:
	set(v):
		player_jump = clamp(v, player_jump_min, player_jump_max)
		Signalbus.player_jump_updated.emit(player_jump)
#endregion
#region grab buffer slider
@export_group("grab buffer", "grab_buffer")
@export var grab_buffer_min: float = 0
@export var grab_buffer_max: float = 11
@export var grab_buffer_default:float = 2
@export var grab_buffer_step: float = 1

var grab_buffer:float = grab_buffer_default:
	set(v):
		grab_buffer = clamp(v, grab_buffer_min, grab_buffer_max)
		Signalbus.grab_buffer_updated.emit(grab_buffer)
#endregion
#region max grab length slider
@export_group("max grab length", "max_grab_length")
@export var max_grab_length_min: float = 0
@export var max_grab_length_max: float = 12
@export var max_grab_length_default:float = 6
@export var max_grab_length_step: float = 1

var max_grab_length:float = max_grab_length_default:
	set(v):
		max_grab_length = clamp(v, max_grab_length_min, max_grab_length_max)
		Signalbus.max_grab_length_updated.emit(max_grab_length)
#endregion
#region box open timer slider
@export_group("box open timer", "box_open_timer")
@export var box_open_timer_min: float = 0
@export var box_open_timer_max: float = 11
@export var box_open_timer_default:float = 1.25
@export var box_open_timer_step: float = 0.1

var box_open_timer:float = box_open_timer_default:
	set(v):
		box_open_timer = clamp(v, box_open_timer_min, box_open_timer_max)
		Signalbus.box_open_timer_updated.emit(box_open_timer)
#endregion
