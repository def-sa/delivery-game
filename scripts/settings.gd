extends Node

##Display

##Gameplay

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
#----------------------------------
##Debug

#--------



func _clamp_to_slider_settings(value, settings):
	value = clamp(value,settings[2],settings[3])
	return value
