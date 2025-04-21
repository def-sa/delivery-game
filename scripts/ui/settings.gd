extends Node

@export_category("Display")
#region brightness
@export_group("brightness", "brightness")
#@export var brightness_name:String = "brightness"
@export_range(0, 1, 0.01, "or_greater") var brightness_min: float = 0.001
@export_range(0, 8, 0.01, "or_greater") var brightness_max: float = 8
@export var brightness_default:float = 1
@export var brightness_step: float = 0.01

var brightness:float = brightness_default:
	set(v):
		brightness = clamp(v, brightness_min, brightness_max)
		Signalbus.brightness_updated.emit(brightness)
#endregion
#region contrast
@export_group("contrast", "contrast")
#@export var contrast_name:String = "contrast"
@export_range(0, 1, 0.01, "or_greater") var contrast_min: float = 0.001
@export_range(0, 8, 0.01, "or_greater") var contrast_max: float = 8
@export var contrast_default:float = 1
@export var contrast_step: float = 0.01

var contrast:float = contrast_default:
	set(v):
		contrast = clamp(v, contrast_min, contrast_max)
		Signalbus.contrast_updated.emit(contrast)
#endregion
#region saturation
@export_group("saturation", "saturation")
#@export var saturation_name:String = "saturation"
@export_range(0, 1, 0.01, "or_greater") var saturation_min: float = 0.001
@export_range(0, 8, 0.01, "or_greater") var saturation_max: float = 8
@export var saturation_default:float = 1
@export var saturation_step: float = 0.01

var saturation:float = saturation_default:
	set(v):
		saturation = clamp(v, saturation_min, saturation_max)
		Signalbus.saturation_updated.emit(saturation)
#endregion

@export_category("Gameplay")
#region render distance
@export_group("render distance", "render_distance")
#@export var render_distance_name:String = "render_distance"
@export_range(0, 1, 0.01, "or_greater") var render_distance_min: int = 2
@export_range(0, 8, 0.01, "or_greater") var render_distance_max: int = 22
@export var render_distance_default:int = 6
@export var render_distance_step: int = 1

var render_distance:int = render_distance_default:
	set(v):
		render_distance = clamp(v, render_distance_min, render_distance_max)
		Signalbus.render_distance_updated.emit(render_distance)
#endregion

@export_category("Audio")
#region main volume
@export_group("main volume", "main_volume")
@export_range(0, 1, 0.01, "or_greater") var main_volume_min: int = 0
@export_range(0, 8, 0.01, "or_greater") var main_volume_max: int = 100
@export var main_volume_default:int = 50
@export var main_volume_step: int = 1

var main_volume:int = main_volume_default:
	set(v):
		main_volume = clamp(v, main_volume_min, main_volume_max)
		Signalbus.main_volume_updated.emit(main_volume)
#endregion

@export_category("Controls")
#region fov
@export_group("fov", "fov")
#@export var fov_name:String = "fov"
@export_range(0, 1, 0.01, "or_greater") var fov_min: int = 1
@export_range(0, 8, 0.01, "or_greater") var fov_max: int = 179
@export var fov_default:int = 95
@export var fov_step: int = 1

var fov:int = fov_default:
	set(v):
		fov = clamp(v, fov_min, fov_max)
		Signalbus.fov_updated.emit(fov)
#endregion
#region sensitivity
@export_group("sensitivity", "sensitivity")
#@export var sensitivity_name:String = "sensitivity"
@export_range(0, 1, 0.01, "or_greater") var sensitivity_min: int = 1
@export_range(0, 8, 0.01, "or_greater") var sensitivity_max: int = 100
@export var sensitivity_default:int = 44
@export var sensitivity_step: int = 1

var sensitivity:int = sensitivity_default:
	set(v):
		sensitivity = clamp(v, sensitivity_min, sensitivity_max)
		Signalbus.sensitivity_updated.emit(sensitivity)
#endregion

@export_category("Debug")
#region player speed
@export_group("player speed", "player_speed")
#@export var player_speed_name:String = "player_speed"
@export_range(0, 1, 0.01, "or_greater") var player_speed_min: int = 1
@export_range(0, 8, 0.01, "or_greater") var player_speed_max: int = 250
@export var player_speed_default:int = 12
@export var player_speed_step: int = 1

var player_speed:int = sensitivity_default:
	set(v):
		player_speed = clamp(v, player_speed_min, player_speed_max)
		Signalbus.player_speed_updated.emit(player_speed)
#endregion
#region player jump
@export_group("player jump", "player_jump")
#@export var player_jump_name:String = "player_jump"
@export_range(0, 1, 0.01, "or_greater") var player_jump_min: float = 1
@export_range(0, 8, 0.01, "or_greater") var player_jump_max: float = 250
@export var player_jump_default:float = 12
@export var player_jump_step: float = 1

var player_jump:float = player_jump_default:
	set(v):
		player_jump = clamp(v, player_jump_min, player_jump_max)
		Signalbus.player_jump_updated.emit(player_jump)
#endregion
#region grab buffer
@export_group("grab buffer", "grab_buffer")
#@export var grab_buffer_name:String = "grab_buffer"
@export_range(0, 1, 0.01, "or_greater") var grab_buffer_min: float = 0
@export_range(0, 8, 0.01, "or_greater") var grab_buffer_max: float = 11
@export var grab_buffer_default:float = 2
@export var grab_buffer_step: float = 1

var grab_buffer:float = grab_buffer_default:
	set(v):
		grab_buffer = clamp(v, grab_buffer_min, grab_buffer_max)
		Signalbus.grab_buffer_updated.emit(grab_buffer)
#endregion
#region max grab length
@export_group("max grab length", "max_grab_length")
#@export var max_grab_length_name:String = "max_grab_length"
@export_range(0, 1, 0.01, "or_greater") var max_grab_length_min: float = 0
@export_range(0, 8, 0.01, "or_greater") var max_grab_length_max: float = 12
@export var max_grab_length_default:float = 6
@export var max_grab_length_step: float = 1

var max_grab_length:float = max_grab_length_default:
	set(v):
		max_grab_length = clamp(v, max_grab_length_min, max_grab_length_max)
		Signalbus.max_grab_length_updated.emit(max_grab_length)
#endregion
#region box open timer

@export_group("box open timer", "box_open_timer")
#@export var box_open_timer_name:String = "box_open_timer"
@export_range(0, 1, 0.01, "or_greater") var box_open_timer_min: float = 0
@export_range(0, 8, 0.01, "or_greater") var box_open_timer_max: float = 11
@export var box_open_timer_default:float = 1.25
@export var box_open_timer_step: float = 0.1

var box_open_timer:float = box_open_timer_default:
	set(v):
		box_open_timer = clamp(v, box_open_timer_min, box_open_timer_max)
		Signalbus.box_open_timer_updated.emit(box_open_timer)
#endregion
