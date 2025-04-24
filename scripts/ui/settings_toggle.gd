extends HBoxContainer
@onready var toggle_text: Label = $toggle_text
@onready var toggle_node: CheckButton = $toggle
@onready var toggle_name:String = str(toggle_node.get_parent().name).replace(" ", "_")

func _on_default_btn_pressed() -> void:
	Settings[toggle_name.to_lower()] = Settings[toggle_name+"_default"]
	toggle_node.button_pressed = Settings[toggle_name+"_default"]

func _on_toggle_toggled(toggled_on: bool) -> void:
	Settings[toggle_name.to_lower()] = toggled_on
	toggle_node.button_pressed = toggled_on
