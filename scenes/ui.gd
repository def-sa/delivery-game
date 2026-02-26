extends Control

@onready var module_container: HFlowContainer = $module_container
@onready var chat_container: VBoxContainer = $module_container/chat_container
@onready var player: CharacterBody3D = $"../game/player"
@onready var text_box: HFlowContainer = $text_box
@onready var pause_menu: ColorRect = $pause_menu
@onready var mouse: TextureRect = $mouse
@onready var camera: Camera3D = $"3d_gui/camera"

var mouse_raycast: RayCast3D
var pointer_target
var is_mouse_pointing: bool = false:
	set(v):
		if v == is_mouse_pointing: return
		_set_mouse_state(is_mouse_pointing, v)
		is_mouse_pointing = v

const TEXT_LINE = preload("res://scenes/text_line.tscn")


func _process(delta: float) -> void:
	if is_mouse_pointing == true: _mouse_overlay()
	

func _ready() -> void:
	#mouse ____________
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	is_mouse_pointing = false


func _input(event: InputEvent) -> void:
	#pause ____________
	if event.is_action_pressed("pause"):
		get_tree().paused = !get_tree().paused
		pause_menu.visible = get_tree().paused
		
		var paused = get_tree().paused as bool
		if (paused):
			Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode == Input.MOUSE_MODE_VISIBLE
	#mouse ____________
	if event.is_action_pressed("pause"):
		is_mouse_pointing = true
		
	#tab to enter point mode
	is_mouse_pointing = Input.is_action_pressed("mouse_point_mode")

#text box ____________
func type_in_chat(text):
	var text_line_node = TEXT_LINE.duplicate().instantiate()
	chat_container.add_child(text_line_node)
	text_line_node.text = text
	text_box.release_focus()
	text_box.move_to_front()
	text_box.clear()
func _on_text_edit_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("enter"):
		type_in_chat(str(player.name +" : "+ text_box.text))

func _on_text_edit_text_changed() -> void:
	text_box.text = text_box.text.replace("\t", "")
	text_box.text = text_box.text.replace("\n", "")
	var line := text_box.get_line_count() - 1
	text_box.set_caret_line(line)
	text_box.set_caret_column(text_box.get_line(line).length())

func _on_chat_container_child_order_changed() -> void:
	if chat_container.get_child_count() == 8:
		chat_container.get_child(0).queue_free()
	
	if chat_container.get_child_count() <= 3: return
	
	for i in chat_container.get_child_count():
		chat_container.get_child(i).modulate = Color(1,1,1, clamp(((i+1)*0.35),0.17,0.85))


#mouse
func _set_mouse_state(current_mouse_state, new_mouse_state) -> void:
	if not current_mouse_state and not new_mouse_state: return
	
	#from pointing -> free look
	if current_mouse_state == true and new_mouse_state == false:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		mouse.visible = false
	#from free look -> pointing
	if current_mouse_state == false and new_mouse_state == true:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		mouse.visible = true

func _mouse_overlay():
	if not mouse_raycast:
		mouse_raycast = RayCast3D.new()
		add_child(mouse_raycast)
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_direction = camera.project_ray_normal(mouse_pos)
	var ray_length = 20
	var ray_end = ray_origin + ray_direction * ray_length
	
	var params = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	params.collision_mask = 2
	
	var space_state = camera.get_world_3d().direct_space_state
	var result = space_state.intersect_ray(params)
	
	mouse.modulate = Color(1,1,1,1)
	mouse.position = mouse_pos + Vector2(-4, 3)
	
	if Input.is_action_pressed("lmb"):
		mouse.scale.y = 0.158
	else:
		mouse.scale.y = 0.233
	
	if not result: 
		pointer_target = null
		return
	if result.collider is physics_item:
		mouse.modulate = Color("55ffff")
		pointer_target = result.collider
