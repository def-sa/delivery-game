extends Node

##Display
# Name, Default, Min, Max, Step
var brightness_settings:Array = ["Brightness", 1, 0.001, 8, 0.01]
#Value
var brightness:float = brightness_settings[1]:
	set(value):
		brightness = _clamp_to_slider_settings(value, brightness_settings)
		#is_default, value
		if value == brightness_settings[1]: # if value is default
			Signalbus.brightness_updated.emit(true, value)
		else:
			Signalbus.brightness_updated.emit(false, value)
			

# Name, Default, Min, Max, Step
var contrast_settings :Array = ["Contrast", 1, 0.001, 8, 0.01]
#Value
var contrast:float = contrast_settings[1]:
	set(value):
		contrast = _clamp_to_slider_settings(value, contrast_settings)
		#is_default, value
		if value == contrast_settings[1]: # if value is default
			Signalbus.contrast_updated.emit(true, value)
		else:
			Signalbus.contrast_updated.emit(false, value)
			
			

# Name, Default, Min, Max, Step
var saturation_settings :Array = ["Saturation", 1, 0.001, 8, 0.01]
#Value
var saturation:float = saturation_settings[1]:
	set(value):
		saturation = _clamp_to_slider_settings(value, saturation_settings)
		#is_default, value
		if value == saturation_settings[1]: # if value is default
			Signalbus.saturation_updated.emit(true, value)
		else:
			Signalbus.saturation_updated.emit(false, value)
			
##Gameplay
# Name, Default, Min, Max, Step
var render_distance_settings :Array = ["Render Distance", 16, 2, 22, 1]
#value
var render_distance:int = render_distance_settings[1]:
	set(value): 
		render_distance = _clamp_to_slider_settings(value, render_distance_settings)
		#is_default, value
		if value == render_distance_settings[1]: # if value is default
			Signalbus.render_distance_updated.emit(true, value)
		else:
			Signalbus.render_distance_updated.emit(false, value)


##Controls
# Name, Default, Min, Max, Step
var fov_settings:Array = ["FOV", 95, 1, 179, 1]
#Value
var fov:int = fov_settings[1]:
	set(value):
		fov = _clamp_to_slider_settings(value, fov_settings)
		#is_default, value
		if value == fov_settings[1]: # if value is default
			Signalbus.fov_updated.emit(true, value)
		else:
			Signalbus.fov_updated.emit(false, value)
#----------------------------------
# Name, Default, Min, Max, Step
var sensitivity_settings:Array = ["Sensitivity", 44, 1, 100, 1]
#value
var sensitivity:int = sensitivity_settings[1]:
	set(value): 
		sensitivity = _clamp_to_slider_settings(value, sensitivity_settings)
		#is_default, value
		if value == sensitivity_settings[1]: # if value is default
			Signalbus.sensitivity_updated.emit(true, value)
		else:
			Signalbus.sensitivity_updated.emit(false, value)
#----------------------------------
##Debug

# Name, Default, Min, Max, Step
var player_speed_settings:Array = ["Player Speed", 12, 1, 1000, 1]
#value
var player_speed:int = player_speed_settings[1]:
	set(value): 
		player_speed = _clamp_to_slider_settings(value, player_speed_settings)
		#is_default, value
		if value == player_speed_settings[1]: # if value is default
			Signalbus.player_speed_updated.emit(true, value)
		else:
			Signalbus.player_speed_updated.emit(false, value)
#--------
# Name, Default, Min, Max, Step
var player_jump_settings:Array = ["Player Jump", 6.5, 0, 50, 0.01]
#value
var player_jump:float = player_jump_settings[1]:
	set(value): 
		player_jump = _clamp_to_slider_settings(value, player_jump_settings)
		#is_default, value
		if value == player_jump_settings[1]: # if value is default
			Signalbus.player_jump_updated.emit(true, value)
		else:
			Signalbus.player_jump_updated.emit(false, value)

# Name, Default, Min, Max, Step
var grab_buffer_settings:Array = ["Grab Buffer", 2, 0, 11, 1]
#Value
var grab_buffer:float = grab_buffer_settings[1]:
	set(value):
		grab_buffer = _clamp_to_slider_settings(value, grab_buffer_settings)
		#is_default, value
		if value == grab_buffer_settings[1]: # if value is default
			Signalbus.grab_buffer_cooldown_updated.emit(true, value)
		else:
			Signalbus.grab_buffer_cooldown_updated.emit(false, value)
#---------

# Name, Default, Min, Max, Step
var max_grab_length_settings:Array = ["Max Grab Length", 5.5, 0, 100, 0.5]
#Value
var max_grab_length:float = max_grab_length_settings[1]:
	set(value):
		max_grab_length = _clamp_to_slider_settings(value, max_grab_length_settings)
		#is_default, value
		if value == max_grab_length_settings[1]: # if value is default
			Signalbus.max_grab_length_updated.emit(true, value)
		else:
			Signalbus.max_grab_length_updated.emit(false, value)
#---------




func _clamp_to_slider_settings(value, settings):
	value = clamp(value,settings[2],settings[3])
	return value
