extends HBoxContainer

@onready var slider_text:Label = $slider_text
@onready var slider_value_txt:Label = $slider_value_txt
@onready var slider_node:Slider = $slider
@onready var slider_name:String = str(slider_node.get_parent().name).replace(" ", "_")

func _on_default_btn_pressed() -> void:
	Settings[slider_name.to_lower()] = Settings[slider_name+"_default"]
	slider_value_txt.text = str(Settings[slider_name+"_default"])
	slider_node.value = Settings[slider_name+"_default"]

func _on_slider_value_changed(value: float) -> void:
	Settings[slider_name.to_lower()] = value
	slider_value_txt.text = str(value)
	slider_node.value = value
