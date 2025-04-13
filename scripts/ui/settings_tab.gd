extends TabBar

@onready var v_box_container: VBoxContainer = $VBoxContainer
var sliders_in_display:Array[String]


#TODO : fix sliders 
func _ready() -> void:
	Signalbus.settings_slider.connect(_handle_slider_changed)
	
	#populate sliders_in_display array
	for node in v_box_container.get_children():
		sliders_in_display.push_back(str(node.name))
	
	# for each slider, find set values and set slider
	for slider in sliders_in_display:
		print(slider)
		#[_name, min, max, default, step]
		var slider_node = get_node("VBoxContainer/"+slider)
		var slider_values = _get_slider_values(slider)
		if !slider_values:
			print("could not get slider values")
			return
		
		slider_node.slider_text.text = slider.capitalize()
		slider_node.slider_name = slider.capitalize()
		slider_node.slider_min_value = slider_values[0]
		slider_node.slider_max_value = slider_values[1]
		slider_node.slider_default_value = slider_values[2]
		slider_node.slider_step = slider_values[3]


func _handle_slider_changed(slider_name,is_default,value):
	#print(slider_name,is_default,value)
	for slider in sliders_in_display:
		#print(slider_name)
		if slider_name == slider:
			var slider_values = _get_slider_values(slider)
			print(slider_values,"||| ",slider)
			if !slider_values:
				print("could not get slider values")
				return
			var slider_node = get_node("VBoxContainer/"+slider)
			
			#[_name, min, max, default, step]
			if slider in Settings:
				if is_default == true:
					Settings[slider] = slider_values[2]
				else:
					Settings[slider] = value

func _get_slider_values(get_slider):
	#var _name
	var min
	var max
	var default 
	var step
	
	for slider in sliders_in_display:
		print(get_slider," : ", slider)
		if get_slider == slider:
			#print("triggered")
			#_name = Settings[slider+"_name"]
			min = Settings[slider+"_min"]
			max = Settings[slider+"_max"]
			default = Settings[slider+"_default"]
			step = Settings[slider+"_step"]
			print([min, max, default, step])
	if min != null:
		return [min, max, default, step]
	else:
		return null
