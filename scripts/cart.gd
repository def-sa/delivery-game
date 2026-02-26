extends RigidBody3D


#thank you ,i love you, i cant do physics math good
# https://www.youtube.com/watch?v=9MqmFSn1Rlw&ab_channel=Octodemy

@export var acceleration := 600.0
@export var deceleration := 200.0
@export var max_speed := 20.0


@export var wheels: Array[RayCast3D]
@export var spring_strength := 100.0
@export var spring_damping := 2.0
@export var over_extend := 0.2
@export var rest_dist := 0.5
@export var wheel_radius := 0.4


func _physics_process(_delta: float) -> void:
	var grounded := false
	for wheel in wheels:
		if wheel.is_colliding():
			grounded = true
		wheel.force_raycast_update()
		_do_single_wheel_suspension(wheel)
		_do_single_wheel_acceleration(wheel)
	
	if grounded:
		center_of_mass = Vector3.ZERO
	else:
		center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
		center_of_mass = Vector3.DOWN * 0.5
		
func _get_point_velocity(point: Vector3) -> Vector3:
	return linear_velocity + angular_velocity.cross(point - global_position)

func _do_single_wheel_acceleration(raycast: RayCast3D):
	var forward_dir := -raycast.global_basis.z
	var vel := forward_dir.dot(linear_velocity)
	raycast.get_node("wheel").rotate_x(-vel * get_process_delta_time() / wheel_radius)

func _do_single_wheel_suspension(raycast: RayCast3D) -> void:
	if not raycast.is_colliding(): return
	
	raycast.target_position.y = -(rest_dist + wheel_radius + over_extend)
	
	var contact = raycast.get_collision_point()
	var spring_up_dir := raycast.global_transform.basis.y
	var spring_len := raycast.global_position.distance_to(contact) - wheel_radius
	var offset := rest_dist - spring_len
	
	raycast.get_node("wheel").position.y = -spring_len
	
	var spring_force := spring_strength * offset
	
	var world_vel := _get_point_velocity(contact)
	var relative_vel := spring_up_dir.dot(world_vel)
	var spring_damp_force := spring_damping * relative_vel
	#print(spring_damp_force)
	
	var force_vector := (spring_force - spring_damp_force) * raycast.get_collision_normal()
	var force_pos_offset = contact - global_position

	#if vel > max_speed:
		#force_vector *= 0.1
	#print(force_vector.y >= 118 and force_vector.y <= 147)
	apply_force(force_vector, force_pos_offset)
