extends TabBar
@onready var v_box_container: VBoxContainer = $ScrollContainer/VBoxContainer

var elements_in_tab:Array[Node]

func _ready() -> void:
	
	for node in v_box_container.get_children():
		elements_in_tab.push_back(node)
	_update_sliders()
	_update_dropdowns()
	_update_toggles()
	
func _update_sliders():
	for element in elements_in_tab:
		if element.get_child(1) is HSlider and element is HBoxContainer:
			var slider = element
			#[min, max, default, step]
			slider.slider_text.text = (slider.name).capitalize()
			if slider.name in Settings:
				slider.slider_node.min_value = Settings[slider.name+"_min"]
				slider.slider_node.max_value = Settings[slider.name+"_max"]
				slider.slider_node.value = Settings[slider.name+"_default"]
				slider.slider_node.step = Settings[slider.name+"_step"]
				slider.slider_node.scrollable = false

func _update_dropdowns():
	for element in elements_in_tab:
		if element.get_child(1) is OptionButton and element is HBoxContainer:
			if element.name in Settings:
				var dropdown = element.get_child(1)
				var default_option
				
				for option in Settings[element.name+"_selections"]:
					if option == Settings[element.name+"_default"]:
						default_option = option
					dropdown.add_item(option)
				var index_of_default_option = Settings[element.name+"_selections"].find(default_option)
				dropdown.select(index_of_default_option)
				element.dropdown_text.text = (element.name).capitalize()

func _update_toggles():
	for element in elements_in_tab:
		if element.get_child(1) is CheckButton and element is HBoxContainer:
			if element.name in Settings:
				var toggle = element.get_child(1)
				toggle.button_pressed = Settings[element.name+"_default"]
				element.toggle_text.text = (element.name).capitalize()
