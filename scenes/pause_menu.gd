extends ColorRect

@export var pause_menu: ColorRect
@export var v_box_container: VBoxContainer
@export var ui: Control

@onready var resume: Control = $left/resume
@onready var achievements: Control = $left/achievements
@onready var options: Control = $left/options
@onready var exit: Control = $left/exit
@onready var options_menu: TabContainer = $options_menu
@onready var left: VBoxContainer = $left
@onready var right: HBoxContainer = $right
@onready var ui_animation: AnimationPlayer = $"../../ui_animation"
@onready var game: Node3D = $"../../../game"




func _input(event: InputEvent) -> void:
	#pause ____________
	if event.is_action_pressed("pause"):
		pause()

func _process(delta: float) -> void:
	if (not get_tree().paused):
		ui.is_mouse_pointing = Input.is_action_pressed("mouse_point_mode")


func pause():
	get_tree().paused = !get_tree().paused
	ui_animation.play("pause_fade_in")
	pause_menu.visible = get_tree().paused
	ui.is_mouse_pointing = get_tree().paused
	options_menu.visible = false
	left.visible = true
	right.visible = false

func _on_pause_menu_visibility_changed() -> void:
	for child in v_box_container.get_children():
		if not child.has_method("play_animation"): return
		child.play_animation()
	
func _ready():
	pause_menu.visible = false
	options_menu.visible = false
	left.visible = true
	right.visible = false 
	
	for child in v_box_container.get_children():
		if child.has_signal("button_selected"):
			child.button_selected.connect(_on_button_selected)






func _on_button_selected(btn):
	match btn:
		resume:
			#save settings
			pause()
			pass
		achievements:
			pass
		options:
			options_menu.visible = !options_menu.visible
			left.visible = !left.visible
			right.visible = !right.visible
			pass
		exit:
			pass
			
	print(btn)



func _on_background_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.is_action("lmb"):
		options_menu.visible = false
		left.visible = true
		right.visible = false
