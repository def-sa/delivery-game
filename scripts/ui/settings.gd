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
var window_display_type_name:String = "window_display_type"
var window_display_type_tooltip:String = "main window mode

can be overridden by entering windowed mode"

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
var vsync_mode_name:String = "vsync_mode"
var vsync_mode_tooltip:String = "

	VSYNC_DISABLED: turns vsync off

	VSYNC_ENABLED: turns vsync on limiting your fps to your monitors refresh rate

	VSYNC_ADAPTIVE: fps is limited by the monitor as if vsync is enabled, however,
	when frames are below the monitors refresh rate it behaves as if vsync has been disabled

	VSYNC_MAILBOX: displays the most recent image with the frame rate being unlimited.
	the image is rendered as fast as possible which could reduce input lag but no guarantees are made.
	this mode is also known as “Fast” Vsync and works best when your frame rate is at least twice that
	of the monitor refresh rate
"
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
var shadow_quality_name:String = "shadow_quality"
var shadow_quality_tooltip:String = "controls positional_shadows, directional_shadows, and the size atlas of the shadows. 

values below `soft_low` use 16 bit shadow depth mapping, and disable atlas quadrant subdivision"

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
var fov_name:String = "fov"
var fov_tooltip:String = "camera fov

higher values may reduce framerate depending on how much is on screen at once"

var fov:int = fov_default:
	set(v):
		fov = clamp(v, fov_min, fov_max)
		Signalbus.fov_updated.emit(fov)
#endregion


#region show_fps toggle
@export_group("show fps", "show_fps")
@export var show_fps_default:bool = true
var show_fps_name:String = "show_fps"
var show_fps_tooltip:String = "show engine fps and debug values.

helpful for tweaking settings"
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
var max_fps_name:String = "max_fps"
var max_fps_tooltip:String = "max engine fps

will be ignored depending on what vsync setting is active"

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
var viewport_width_name:String = "viewport_width"
var viewport_width_tooltip:String = "viewport width

will be set once unpaused"

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
var viewport_height_name:String = "viewport height

will be set once unpaused"
var viewport_height_tooltip = "viewport_height_tooltip"

var viewport_height:float = viewport_height_default:
	set(v):
		viewport_height = clamp(v, viewport_height_min, viewport_height_max)
		Signalbus.viewport_height_updated.emit(viewport_height)
#endregion


#region bilinear filtering toggle
@export_group("bi/tri linear filtering", "bilinear_filtering")
@export var bilinear_filtering_default:bool = true
var bilinear_filtering_name:String = "bilinear filtering"
var bilinear_filtering_tooltip:String = "if toggled bilinear filtering will be used
if not toggled trilinear filtering will be used"

var bilinear_filtering:bool = bilinear_filtering_default:
	set(v):
		bilinear_filtering = v
		Signalbus.bilinear_filtering_updated.emit(bilinear_filtering)
#endregion


#region screen_space_reflections toggle
@export_group("screen_space_reflections", "screen_space_reflections")
@export var screen_space_reflections_default:bool = false
var screen_space_reflections_name:String = "screen_space_reflections"
var screen_space_reflections_tooltip:String = "toggle screen space reflections"

var screen_space_reflections:bool = bilinear_filtering_default:
	set(v):
		screen_space_reflections = v
		Signalbus.screen_space_reflections_updated.emit(screen_space_reflections)
#endregion

#Screen-Space Ambient Occlusion 

#region screen_space_reflections toggle
@export_group("screen_space_ambient_occlusion", "screen_space_ambient_occlusion")
@export var screen_space_ambient_occlusion_default:bool = false
var screen_space_ambient_occlusion_name:String = "screen space ambient occlusion"
var screen_space_ambient_occlusion_tooltip:String = "toggle screen_space_ambient_occlusion"

var screen_space_ambient_occlusion:bool = screen_space_ambient_occlusion_default:
	set(v):
		screen_space_ambient_occlusion = v
		Signalbus.screen_space_ambient_occlusion_updated.emit(screen_space_ambient_occlusion)
#endregion

#Screen-Space Indirect Lighting

#region screen_space_indirect_lighting toggle
@export_group("screen_space_indirect_lighting", "screen_space_indirect_lighting")
@export var screen_space_indirect_lighting_default:bool = false
var screen_space_indirect_lighting_name:String = "screen_space_indirect_lighting"
var screen_space_indirect_lighting_tooltip:String = "toggle screen_space_indirect_lighting"

var screen_space_indirect_lighting:bool = screen_space_indirect_lighting_default:
	set(v):
		screen_space_indirect_lighting = v
		Signalbus.screen_space_indirect_lighting_updated.emit(screen_space_indirect_lighting)
#endregion


#Signed Distance Field Global Illumination

#region sdfgi toggle
@export_group("sdfgi", "sdfgi")
@export var sdfgi_default:bool = false
var sdfgi_name:String = "sdfgi"
var sdfgi_tooltip:String = "toggle Signed Distance Field Global Illumination"


var sdfgi:bool = sdfgi_default:
	set(v):
		sdfgi = v
		Signalbus.sdfgi_updated.emit(sdfgi)
#endregion


#scanner_flashing

#region scanner_flashing toggle
@export_group("scanner_flashing", "scanner_flashing")
@export var scanner_flashing_default:bool = true
var scanner_flashing_name:String = "scanner flashing"
var scanner_flashing_tooltip:String = "toggle Signed Distance Field Global Illumination"


var scanner_flashing:bool = scanner_flashing_default:
	set(v):
		scanner_flashing = v
		Signalbus.scanner_flashing_updated.emit(scanner_flashing)
#endregion




#region occlusion_culling dropdown
@export_group("occlusion culling", "occlusion_culling")
@export var occlusion_culling_selections:Array[String] = [
	"low",
	"medium",
	"high"
	]
var occlusion_culling_default:String = occlusion_culling_selections[1]
var occlusion_culling_name:String = "occlusion culling"
var occlusion_culling_tooltip:String = "occlusion culling is enabled by default to help with performance. 
if you notice things flickering into view try making this setting higher"

var occlusion_culling:String = occlusion_culling_default:
	set(v):
		if occlusion_culling_selections.has(v):
			occlusion_culling = v
			Signalbus.occlusion_culling_updated.emit(occlusion_culling)
#endregion


#region texture_filter dropdown
@export_group("texture filter", "texture_filter_name")
@export var texture_filter_selections:Array[String] = [
	"nearest",
	"linear",
	"linear mipmap",
	"nearest mipmap"
	]
var texture_filter_default:String = texture_filter_selections[0]
var texture_filter_name:String = "texture filter"
var texture_filter_tooltip:String = "texture_filter_tooltip"

var texture_filter:String = texture_filter_default:
	set(v):
		if texture_filter_selections.has(v):
			texture_filter = v
			Signalbus.texture_filter_updated.emit(texture_filter)
#endregion

#region reflections dropdown
@export_group("reflections", "reflections")
@export var reflections_selections:Array[String] = [
	"lowest",
	"low",
	"default",
	"high",
	"ultra"
	]
var reflections_default:String = reflections_selections[0]
var reflections_name:String = "reflections"
var reflections_tooltip:String = "reflections_tooltip"

var reflections:String = reflections_default:
	set(v):
		if reflections_selections.has(v):
			reflections = v
			Signalbus.reflections_updated.emit(reflections)
#endregion


#region brightness slider
@export_group("brightness", "brightness")
@export var brightness_min: float = 0.001
@export var brightness_max: float = 8
@export var brightness_default:float = 1
@export var brightness_step: float = 0.01
var brightness_name:String = "brightness"
var brightness_tooltip:String = "brightness_tooltip"

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
var contrast_name:String = "contrast"
var contrast_tooltip:String = "contrast_tooltip"

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
var saturation_name:String = "saturation"
var saturation_tooltip:String = "saturation_tooltip"

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
var render_distance_name:String = "render_distance"
var render_distance_tooltip:String = "render_distance_tooltip"

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
var main_volume_name:String = "main_volume"
var main_volume_tooltip:String = "main_volume_tooltip"

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
var sensitivity_name:String = "sensitivity"
var sensitivity_tooltip:String = "sensitivity_tooltip"

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
var player_speed_name:String = "player_speed"
var player_speed_tooltip:String = "player_speed_tooltip"

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
var player_jump_name:String = "player_jump"
var player_jump_tooltip:String = "player_jump_tooltip"

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
var grab_buffer_name:String = "grab_buffer"
var grab_buffer_tooltip:String = "player_jump_tooltip"

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
var max_grab_length_name:String = "max_grab_length"
var max_grab_length_tooltip:String = "max_grab_length_tooltip"

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
var box_open_timer_name:String = "box_open_timer"
var box_open_timer_tooltip:String = "box_open_timer_tooltip"

var box_open_timer:float = box_open_timer_default:
	set(v):
		box_open_timer = clamp(v, box_open_timer_min, box_open_timer_max)
		Signalbus.box_open_timer_updated.emit(box_open_timer)
#endregion
