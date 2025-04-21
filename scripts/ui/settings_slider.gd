extends HBoxContainer

@onready var slider_text:Label = $slider_text
@onready var slider_value_txt:Label = $slider_value_txt
@onready var slider_node:Slider = $slider

@onready var slider_name:String = str(slider_node.get_parent().name).replace(" ", "_")
		
@onready var slider_default_value:float = 50:
	set(value):
		slider_value_txt.text = str(value)
		slider_node.value = value
		slider_default_value = value
@onready var slider_min_value:float = 0:
	set(value):
		slider_min_value = value
		slider_node.min_value = value
		
@onready var slider_max_value:float = 100:
	set(value):
		slider_max_value = value
		slider_node.max_value = value
	
@onready var slider_step:float = 0.001:
	set(value):
		slider_step = value
		slider_node.step = value

func _on_default_btn_pressed() -> void:
	Settings[slider_name.to_lower()] = Settings[slider_name+"_default"]
	slider_value_txt.text = str(slider_default_value)
	slider_node.value = slider_default_value

func _on_slider_value_changed(value: float) -> void:
	Settings[slider_name.to_lower()] = value
	slider_value_txt.text = str(value)
	slider_node.value = value
