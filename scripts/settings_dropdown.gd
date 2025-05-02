extends HBoxContainer

@onready var dropdown_text: Label = $dropdown_text
@onready var dropdown_node: OptionButton = $dropdown
@onready var default_btn: TextureButton = $default_btn
@onready var dropdown_name:String = str(dropdown_node.get_parent().name).replace(" ", "_")

func _ready() -> void:
	Signalbus[dropdown_name+"_updated"].connect(_signal_updated)
	
	dropdown_text.tooltip_text = Settings[dropdown_name+"_tooltip"]
	dropdown_node.tooltip_text = Settings[dropdown_name+"_tooltip"]

func _on_default_btn_pressed() -> void:
	var default = Settings[dropdown_name+"_default"]
	var index = Settings[dropdown_name+"_selections"].find(default)
	dropdown_node.select(index)
	Settings[dropdown_name] = Settings[dropdown_name+"_selections"][index]

func _on_dropdown_item_selected(index: int) -> void:
	var selected = Settings[dropdown_name+"_selections"][index]
	Settings[dropdown_name] = selected

func _signal_updated(value: String):
	var index = Settings[dropdown_name+"_selections"].find(value)
	dropdown_node.select(index)
