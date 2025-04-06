extends Control

#object
var objects_inside_area = []:
	set(v):
		objects_inside_area = v


#[object, corrosponding rectangle, on screen notifier]
var connected_nodes_array = []


#update rectangle, and  screen notifier position
func _physics_process(delta: float) -> void:
	
	for obj in objects_inside_area:
		var current_object = obj
		for node in connected_nodes_array:
			if current_object == node[0]:
				var current_object_mesh = get_object_mesh(current_object)
				
				var current_rectangle = node[1]
				var current_on_screen_notifier = node[2]
				
				current_on_screen_notifier.aabb = current_object_mesh.get_aabb()
				var bounding_box = get_2d_bounding_box(current_object_mesh)
				current_rectangle.position = bounding_box.position
				current_rectangle.size = bounding_box.size
				
				#if current_on_screen_notifier.is_on_screen() == true:
				
				#if current_on_screen_notifier.is_on_screen() == false:

func item_entered_area(object):
	#if nodes connected and saved, return 
	for node in connected_nodes_array:
		if object == node[0]:
			return
	
	if object.is_in_group("detectable"):
		var rectangle = ReferenceRect.new()
		rectangle.border_width = 1
		rectangle.editor_only = false
		var current_object_mesh = get_object_mesh(object)
		var bounding_box = get_2d_bounding_box(current_object_mesh)
		rectangle.position = bounding_box.position
		rectangle.size = bounding_box.size
		
		var on_screen_notifier = VisibleOnScreenNotifier3D.new()
		on_screen_notifier.aabb = object.mesh.get_aabb()
		
		connected_nodes_array.push_front([object, rectangle, on_screen_notifier])
		add_child(rectangle)
		add_child(on_screen_notifier)
		print("created", object)

func item_exited_area(object):
	for node in connected_nodes_array:
		if object == node[0]:
			var current_object = node[0]
			var current_rectangle = node[1]
			var current_on_screen_notifier = node[2]
			current_rectangle.queue_free()
			current_on_screen_notifier.queue_free()
			connected_nodes_array.erase(node)
			print("deleted", current_object)

func get_2d_bounding_box(mesh_instance: MeshInstance3D) -> Rect2:
	# Get the bounding box (AABB) of the 3D object
	var aabb = mesh_instance.get_aabb()
	
	# List of 3D corners of the bounding box
	var corners = [
		aabb.position,
		aabb.position + Vector3(aabb.size.x, 0, 0),
		aabb.position + Vector3(0, aabb.size.y, 0),
		aabb.position + Vector3(0, 0, aabb.size.z),
		aabb.position + Vector3(aabb.size.x, aabb.size.y, 0),
		aabb.position + Vector3(0, aabb.size.y, aabb.size.z),
		aabb.position + Vector3(aabb.size.x, 0, aabb.size.z),
		aabb.position + aabb.size,
	]
	
	# Project each corner into 2D screen space
	var screen_positions = []
	for corner in corners:
		# Transform the corner to world space
		var global_corner = mesh_instance.global_transform.basis * corner + mesh_instance.global_transform.origin
		var screen_pos = get_viewport().get_camera_3d().unproject_position(global_corner)
		screen_positions.append(screen_pos)
	
	# Find the 2D bounding box
	var min_x = screen_positions[0].x
	var min_y = screen_positions[0].y
	var max_x = screen_positions[0].x
	var max_y = screen_positions[0].y
	
	for pos in screen_positions:
		min_x = min(min_x, pos.x)
		min_y = min(min_y, pos.y)
		max_x = max(max_x, pos.x)
		max_y = max(max_y, pos.y)
	
	# Return the 2D bounding box
	return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))

func get_object_mesh(object):
	if object.get_child_count() >= 1:
			#get mesh instance
			for child in object.get_children():
				if child is MeshInstance3D:
					return child
