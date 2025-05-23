extends MeshInstance3D

func _process(delta: float) -> void:
	#var material_x_offset = 
	get_surface_override_material(0).uv1_offset.x += delta * 1
	if get_surface_override_material(0).uv1_offset.x >= 1:
		get_surface_override_material(0).uv1_offset.x = 0
