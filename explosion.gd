extends Area3D

var connected_physics_item

var explosion_radius = 1
var explosion_force = 5
#var animation

@onready var collision_shape_3d: CollisionShape3D = $collision_shape_3d

@export var size_curve: Curve
@export var falloff_curve: Curve
var duration: float = 0.5
@export var max_scale: float = 5.0  # Maximum scale of the explosion

var time_passed := 0.0

func _physics_process(delta: float) -> void:
	time_passed += delta
	var t = time_passed / duration
	if t >= 1.0:
		connected_physics_item.kill_item()
		queue_free()
		return

	# Evaluate curve (t is between 0 and 1)
	var curve_value = size_curve.sample(t)
	collision_shape_3d.shape.radius = 1 * lerp(1.0, max_scale, curve_value)
	collision_shape_3d.global_position = connected_physics_item.current_box.global_position


func _on_body_entered(body: Node3D) -> void:
	var direction = (body.global_transform.origin - global_transform.origin)
	var distance = direction.length()
	if distance == 0:
		return  # avoid division by zero

	direction = direction.normalized()

	var falloff := 1.0
	#if falloff_curve:
	falloff = falloff_curve.sample(clamp(distance / explosion_radius, 0.0, 1.0))
	#else:
	#falloff = 1.0 - clamp(distance / explosion_radius, 0.0, 1.0)  # linear falloff by default

	var force = direction * explosion_force * falloff

	body.apply_central_impulse(force)
