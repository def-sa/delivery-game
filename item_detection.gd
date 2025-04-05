extends Control

#object
var objects_inside_area = []:
	set(v):
		objects_inside_area = v

#[object, corrosponding rectangle]
var detected_objects = []

#object
var detected_obj:
	set(v):
		print("found", v)
		detected_obj = v 

func _physics_process(delta: float) -> void:
	
	if detected_obj:
		if detected_obj[1] == "entered":
			
			#if not detected already 
			for obj in detected_objects:
				if detected_obj[0] == obj[0]:
					return
			
			var object_position = detected_obj[0].get_global_transform().origin
			var rectangle = ReferenceRect.new()
			rectangle.border_width = 2
			rectangle.editor_only = false
			var pos = get_viewport().get_camera_3d().unproject_position(object_position)
			rectangle.position = pos #Vector2((pos.x / 2),(pos.y / 2))
			rectangle.size = Vector2(100,100)
			#rectangle.size = get_viewport().get_camera_3d().unproject_position(object_position)
			
			detected_objects.push_front([detected_obj[0], rectangle])
			add_child(rectangle)

		if detected_obj[1] == "exited":
			
			
			for obj in detected_objects:
				var index = detected_obj.find(obj[0])
				if detected_obj[0] == obj[0]:
					#queue free rectangle
					obj[1].queue_free()
					detected_objects.remove_at(index)
					
					
					
	#var object_position = target_object.get_global_transform().origin
	#ui_box.rect_position = object_position - Vector2(ui_box.rect_size.x / 2, ui_box.rect_size.y / 2)
