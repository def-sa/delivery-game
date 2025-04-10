extends Node3D
@onready var cart: Node3D = $"."
@onready var cart_handle: RigidBody3D = $"."/cart_handle_collision
@onready var cart_handle_collision: CollisionShape3D = $cart_handle_collision/CollisionShape3D
@onready var cart_body: RigidBody3D = $"."/cart_body
@onready var remote_transform = $"."/cart_body/RemoteTransform3D
@onready var player: CharacterBody3D = $"../../Player"
@onready var hand: Marker3D = $"../../Player/camera_pivot/spring_arm_3d/camera/ray_interaction/Path3D/PathFollow3D/hand"
@onready var bodies_in_cart_node: Node3D = $bodies_in_cart
@onready var world: Node3D = $".."

@onready var cart_rails: RigidBody3D = $cart_rails
@onready var area: Area3D = $cart_area
@onready var sticky_area: Area3D = $cart_sticky

@onready var hand_path: Path3D = $"../../Player/camera_pivot/spring_arm_3d/camera/ray_interaction/Path3D"
@onready var hand_path_follow: PathFollow3D = $"../../Player/camera_pivot/spring_arm_3d/camera/ray_interaction/Path3D/PathFollow3D"

const CART_ITEM_VIEW_PRELOAD = preload("res://cart_item_view.tscn")
var cart_item_view

var object_drag = 0.0025
var pull_power = 60
var max_obj_speed = 10

var cart_speed = 1.5

var bodies_in_cart = []

@onready var saved_grab_length = Settings.max_grab_length

func _ready() -> void:
	area.body_entered.connect(_body_entered_cart)
	area.body_exited.connect(_body_exited_cart)
	cart_item_view = CART_ITEM_VIEW_PRELOAD.instantiate()



func _physics_process(delta: float) -> void:
	
	
	#if player.hovered_obj in cart.get_children():
		#player.handle_carrying_gui(cart_item_view, "hovering")
		#Signalbus.box_being_carried.emit(cart_item_view)
	
	
	if player.carrying == cart_handle:
		Settings.max_grab_length = 10
		hand_path_follow.progress_ratio += .5
		
		remote_transform.update_rotation = false
		cart_handle_collision.disabled = true
		
		var new_location = (hand.global_transform.origin  - cart_body.global_transform.origin)
		var distance = (hand.global_transform.origin - cart_body.global_transform.origin).length() * object_drag
		var movement_speed = clamp(distance * pull_power, 0, max_obj_speed)
		
		# rewrite this ///////////
		cart_body.linear_velocity.x = new_location.x * movement_speed * cart_speed
		cart_body.linear_velocity.z = new_location.z * movement_speed * cart_speed
		
		cart_body.rotation.y = lerp(cart_body.rotation.y, cart_handle.rotation.y, 1)
		
		#for child in bodies_in_cart_node.get_children():
			#child.linear_velocity.x = new_location.x * movement_speed * cart_speed
			#child.linear_velocity.z = new_location.z * movement_speed * cart_speed
			#
			
		#////////////
		
	else:
		Settings.max_grab_length = saved_grab_length
		remote_transform.update_rotation = true
		remote_transform.update_position = true
		cart_handle_collision.disabled = false



func _body_entered_cart(body: Node3D):
	if body != cart_body and body != cart_rails:
		
		body.reparent(bodies_in_cart_node)
		bodies_in_cart.push_front(body)
		
		if "in_cart" in body:
			body.in_cart = true
		
		print(body.get_path())

func _body_exited_cart(body: Node3D):
	if body != cart_body and body != cart_rails:
		
		for child in cart_body.get_children():
			if child is RemoteTransform3D:
				if child.remote_path == body.get_path():
					child.queue_free()
					
		
		body.reparent(world)
		
		var index = bodies_in_cart.find(body)
		if index != -1:
			bodies_in_cart.remove_at(index)
		if "in_cart" in body:
			body.in_cart = false
