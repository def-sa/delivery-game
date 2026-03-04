extends GPUParticles3D

#var ray_result
#var particle_collision_box
#
#func _ready() -> void:
	#self.restart()
	#
	#particle_collision_box = GPUParticlesCollisionBox3D.new()
	#
	#
	#var mesh = MeshInstance3D.new()
	#var box = BoxMesh.new()
	#box.size = Vector3(5,1,5)
	#mesh.mesh = box
	#particle_collision_box.add_child(mesh)
	#
	#self.add_child(particle_collision_box)
	#particle_collision_box.size = Vector3(5,1,5)
	#particle_collision_box.global_position = global_position
	#particle_collision_box.set_layer_mask_value(1, true)
	#particle_collision_box.set_layer_mask_value(1, true)
	#
	#
	#self.connect("finished", _on_particle_finished)
	#
	##raycast.force_raycast_update()
#
#func _process(delta: float) -> void:
	#if ray_result:
		#particle_collision_box.global_position = ray_result["position"]
		##print(particle_collision_box.global_position)
		#return
	#if not ray_result:
		#var direct_state = get_world_3d().direct_space_state
		#print(position + Vector3(0,-10,0))
		#var parameters = PhysicsRayQueryParameters3D.create(position, position + Vector3(0,-10,0))
		#parameters.collision_mask = 1
		#ray_result = direct_state.intersect_ray(parameters)
		##print(ray_result)
	#
	#
	#
#
#
#func _on_particle_finished():
	#print("particle finsihed")
	#queue_free()
