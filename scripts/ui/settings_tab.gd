extends TabBar

@onready var v_box_container: VBoxContainer = $VBoxContainer
var elements_in_tab:Array[Node]

func _ready() -> void:
	
	for node in v_box_container.get_children():
		elements_in_tab.push_back(node)
	_update_sliders()
	_update_dropdowns()

func _update_sliders():
	for element in elements_in_tab:
		if element.get_child(1) is HSlider:
			var slider = element
			#[min, max, default, step]
			slider.slider_text.text = (slider.name).capitalize()
			slider.slider_min_value = Settings[slider.name+"_min"]
			slider.slider_max_value = Settings[slider.name+"_max"]
			slider.slider_default_value = Settings[slider.name+"_default"]
			slider.slider_step = Settings[slider.name+"_step"]

func _update_dropdowns():
	for element in elements_in_tab:
		if element.get_child(1) is OptionButton:
			var dropdown = element.get_child(1)
			print(dropdown)
			for option in Settings[element.name+"_selections"]:
				dropdown.add_item(option)
			element.dropdown_text.text = (element.name).capitalize()
