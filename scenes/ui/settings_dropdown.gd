extends HBoxContainer

@onready var dropdown_text: Label = $dropdown_text
@onready var dropdown_node: OptionButton = $dropdown
@onready var default_btn: TextureButton = $default_btn


@onready var dropdown_name:String = str(dropdown_node.get_parent().name).replace(" ", "_")
@onready var dropdown_default_value:String = "Default"

func _on_default_btn_pressed() -> void:
	var default = Settings[dropdown_name+"_default"]
	var index = Settings[dropdown_name+"_selections"].find(default)
	dropdown_node.select(index)
	Settings[dropdown_name] = Settings[dropdown_name+"_selections"][index]

func _on_dropdown_item_selected(index: int) -> void:
	var selected = Settings[dropdown_name+"_selections"][index]
	Settings[dropdown_name] = selected
