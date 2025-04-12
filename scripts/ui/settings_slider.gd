extends HBoxContainer

@onready var slider_text:Label = $slider_text
@onready var slider_value_txt:Label = $slider_value_txt
@onready var slider:Slider = $slider

var slider_name:String = "settings_slider":
	set(value):
		slider_name = value
		slider_text.text = value
		
var slider_default_value:float = 50:
	set(value):
		slider.value = value
		slider_default_value = value
var slider_min_value:float = 0:
	set(value):
		slider_min_value = value
		slider.min_value = value
		
var slider_max_value:float = 100:
	set(value):
		slider_max_value = value
		slider.max_value = value
	
var slider_step:float = 0.001:
	set(value):
		slider_step = value
		slider.step = value

func _on_default_btn_pressed() -> void:
	Signalbus.settings_slider.emit(slider_name, true, 0)
	slider_value_txt.text = str(slider_default_value)
	slider.value = slider_default_value

func _on_slider_value_changed(value: float) -> void:
	Signalbus.settings_slider.emit(slider_name, false, value)
	slider_value_txt.text = str(value)
	slider.value = value
