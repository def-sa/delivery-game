extends Control

@onready var h_slider: HSlider = $h_slider
@onready var label: Label = $label
var text : String =  "settings_range"
var min_range = 0
var max_range = 100

func _ready() -> void:
	
