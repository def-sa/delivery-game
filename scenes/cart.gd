extends Node3D

@onready var cart_handle: RigidBody3D = $"."/cart_handle
@onready var cart_body: RigidBody3D = $"."/cart_body

var object_drag = 0.0075
var pull_power = 10
var max_obj_speed = 10


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	var a = cart_body.global_transform.origin
	var b = cart_handle.global_transform.origin
	var direction = (b - a)
	var distance = (b - a).length() * object_drag
	var movement_speed = clamp(distance * pull_power, 0, max_obj_speed)
	
	cart_body.linear_velocity = direction * movement_speed
