extends TabBar

## Name, Default, Min, Max, Step
#var grab_buffer_settings = Settings.grab_buffer_settings
#var grab_buffer = Settings.grab_buffer

var slider_controls :Array= [
	Settings.brightness_settings,
	Settings.contrast_settings,
	Settings.saturation_settings
	]

func _ready() -> void:
	#for each array of settings, create sliders
	for i in slider_controls:
		var setting = slider_controls[slider_controls.find(i)]
		#relies on node name to be the same as in the settings arrays , probably bad but whatever
		set_slider_settings(setting, get_node("VBoxContainer/"+setting[0]))
	Signalbus.settings_slider.connect(_handle_slider_changed)
	

func _handle_slider_changed(slider_name,is_default,value):
	match slider_name:
		"Brightness":
			if is_default == true:
				Settings.brightness = Settings.brightness_settings[1]
			else:
				Settings.brightness = value
		"Contrast":
			if is_default == true:
				Settings.contrast = Settings.contrast_settings[1]
			else:
				Settings.contrast = value
		"Saturation":
			if is_default == true:
				Settings.saturation = Settings.saturation_settings[1]
			else:
				Settings.saturation = value
		"Placeholder":
			pass

# array = Name, Default, Min, Max, Step
func set_slider_settings(settings_array, reference):
	reference.slider_text.text = settings_array[0]
	reference.slider_name = settings_array[0]
	reference.slider_default_value = settings_array[1]
	reference.slider_min_value = settings_array[2]
	reference.slider_max_value = settings_array[3]
	reference.slider_step = settings_array[4]
