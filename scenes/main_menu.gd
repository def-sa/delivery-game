extends Node3D

@onready var camera: Camera3D = $"../camera_3d"
@onready var phys_menu_list: Node3D = $phys_menu_list


@export var drag_force_strength: float = 2500
@export var let_go_impulse = Vector3(0,0,-10)

var selected_body: RigidBody3D = null
var dragging: bool = false

func _physics_process(delta: float) -> void:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var ray_origin: Vector3 = camera.project_ray_origin(mouse_pos)
	var ray_direction: Vector3 = camera.project_ray_normal(mouse_pos)
	var ray_length: float = 100
	var space_state = get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.new()
	params.from = ray_origin
	params.to = ray_origin + ray_direction * ray_length
	var result = space_state.intersect_ray(params)
	if result:
		if result.collider is RigidBody3D:
			selected_body = result.collider
	
	if dragging and selected_body:
		selected_body.apply_central_force(let_go_impulse)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("lmb"):
		dragging = true
	if event.is_action_released("lmb"):
		if selected_body:
			selected_body.apply_central_impulse(let_go_impulse)
		dragging = false
		selected_body = null


@export_range(1, 6) var num_of_menu_items: int = 3:
	set(v):
		num_of_menu_items = v
		refresh()

@export var button_padding: float = 1.0:
	set(v):
		button_padding = v
		refresh()
@export var can_sleep: bool = false
@export var exclude_nodes_from_collision: bool = false
@export var menu_position: Vector3 = position:
	set(v):
		menu_position = v
		position = menu_position

@export var button_size: Vector3 = Vector3(1, 1, 1):
	set(v):
		button_size = v
		refresh()

@export var buttons_names: Array[String]

@export var button_textures: Array[CompressedTexture2D]:
	set(v):
		button_textures = v
		refresh()
@export var button_texture_uv1_scale: Vector3 = Vector3(1, 1, 1):
		set(v):
			button_texture_uv1_scale = v
			refresh()
@export var button_texture_uv1_offset: Vector3 = Vector3(0, 0, 0):
		set(v):
			button_texture_uv1_offset = v
			refresh()
@export var pin_offset: Vector3 = Vector3.ZERO:
		set(v):
			pin_offset = v
			refresh()

var is_ready = false

var buttons: Array = []
var top_static_body: Node3D

func _ready() -> void:
	top_static_body = StaticBody3D.new()
	top_static_body.position = Vector3.ZERO
	add_child(top_static_body)
	
	var last_button = create_button(top_static_body, 0)
	for i in range(1,num_of_menu_items):
		last_button = create_button(last_button, i)
	print(buttons)
	is_ready = true


func refresh():
	if !is_ready: return
	clear_all()
	buttons.clear()
	top_static_body = null
	
	top_static_body = StaticBody3D.new()
	top_static_body.position = Vector3.ZERO
	add_child(top_static_body)
	
	var last_button = create_button(top_static_body, 0)
	for i in range(1,num_of_menu_items):
		last_button = create_button(last_button, i)
	#print(buttons)

func create_button(parent_node: Node3D, index: int) -> Node3D:
	var button = RigidBody3D.new()
	button.name = buttons_names[index]
	button.can_sleep = can_sleep
	button.position = parent_node.position - Vector3(0, button_size.y + button_padding, 0)
	buttons.append(button)
	add_child(button)
	
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = button_size
	mesh_instance.mesh = box_mesh
	
	var material = StandardMaterial3D.new()
	if button_textures.size() > index:
		material.albedo_texture = button_textures[index]
	material.uv1_scale = button_texture_uv1_scale
	material.uv1_offset = button_texture_uv1_offset
	mesh_instance.set_surface_override_material(0, material)
	button.add_child(mesh_instance)
	
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = button_size
	collision_shape.shape = box_shape
	button.add_child(collision_shape)
	
	var pin_joint = PinJoint3D.new()
	pin_joint.node_a = parent_node.get_path()
	pin_joint.node_b = button.get_path()
	
	pin_joint.position = ((parent_node.position + button.position) * 0.5) + pin_offset
	pin_joint.exclude_nodes_from_collision = exclude_nodes_from_collision
	add_child(pin_joint)
	
	return button

func clear_all():
	for child in get_children():
		child.queue_free()
