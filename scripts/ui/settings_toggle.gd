extends HBoxContainer
@onready var toggle_text: Label = $toggle_text
@onready var toggle_node: CheckButton = $toggle
@onready var toggle_name:String = str(toggle_node.get_parent().name).replace(" ", "_")

func _ready() -> void:
	Signalbus[toggle_name+"_updated"].connect(_signal_updated)
	
	toggle_text.tooltip_text = Settings[toggle_name+"_tooltip"]
	toggle_node.tooltip_text = Settings[toggle_name+"_tooltip"]

func _on_default_btn_pressed() -> void:
	Settings[toggle_name.to_lower()] = Settings[toggle_name+"_default"]
	toggle_node.button_pressed = Settings[toggle_name+"_default"]

func _on_toggle_toggled(toggled_on: bool) -> void:
	Settings[toggle_name.to_lower()] = toggled_on
	toggle_node.button_pressed = toggled_on

func _signal_updated(value: bool):
	toggle_node.button_pressed = value
