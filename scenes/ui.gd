extends Control

@export var pause_menu: ColorRect
@export var mouse: TextureRect
@export var camera: Camera3D


var mouse_raycast: RayCast3D
var pointer_target
var is_mouse_pointing: bool = false:
	set(v):
		if v == is_mouse_pointing: return
		_set_mouse_state(is_mouse_pointing, v)
		is_mouse_pointing = v


func process(delta: float) -> void:
	if is_mouse_pointing == true: _mouse_overlay()
	

func _ready() -> void:
	#mouse ____________
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

#mouse
func _set_mouse_state(current_mouse_state, new_mouse_state) -> void:
	if not current_mouse_state and not new_mouse_state: return
	
	#from pointing -> free look
	if current_mouse_state == true and new_mouse_state == false:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		mouse.visible = false
	#from free look -> pointing
	if current_mouse_state == false and new_mouse_state == true:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
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
