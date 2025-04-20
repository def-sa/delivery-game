extends Control
@onready var player: CharacterBody3D = $"../../.."
#@onready var box: RigidBody3D = $World/box
@onready var camera: Camera3D = $"../../../camera_pivot/spring_arm_3d/camera"
@onready var offscreen_reticle: TextureRect = $offscreen_reticle
@onready var negative_shader = preload("res://shaders/negative.gdshader")

#object
var objects_inside_area = []:
	set(v):
		# NOTE: ONLY PASS ARRAYS INTO THIS
		v.erase(player)
		objects_inside_area = v

#[object, current ui container]
var connected_nodes_array = []

@onready var viewport_center = Vector2(get_viewport().size) / 2.0
@onready var border_offset = Vector2(32, 32)
@onready var max_reticle_position = viewport_center - border_offset
var reticle_offset = Vector2(32, 32)


#object reticle, thank you 
# https://www.youtube.com/watch?v=EKVYfF8oG0s
func _process(delta: float) -> void:
	if objects_inside_area.is_empty():
		offscreen_reticle.hide()
	
	for obj in objects_inside_area:
		if obj:
			if camera.is_position_in_frustum(obj.global_position):
				offscreen_reticle.hide()
				#var reticle_position = camera.unproject_position(obj.global_position)
			else:
				offscreen_reticle.show()
				var local_to_camera = camera.to_local(obj.global_position)
				var reticle_position = Vector2(local_to_camera.x, -local_to_camera.y)
				if reticle_position.abs().aspect() > max_reticle_position.aspect():
					reticle_position *= max_reticle_position.x / abs(reticle_position.x)
				else:
					reticle_position *= max_reticle_position.y / abs(reticle_position.y)
				offscreen_reticle.set_global_position(max_reticle_position + reticle_position - reticle_offset)
				var angle = Vector2.UP.angle_to(reticle_position)
				offscreen_reticle.rotation = angle






#update rectangle, and  screen notifier position
func _physics_process(delta: float) -> void:
	for obj in objects_inside_area:
		
		var obj_on_screen = true
		var visible_on_screen_notifier = get_on_screen_notifier(obj)
		if visible_on_screen_notifier:
			if visible_on_screen_notifier.is_on_screen() == false:
				obj_on_screen = false
		var current_object = obj
		
		for node in connected_nodes_array:
			if current_object == node[0]:
				var current_ui_container = node[1]
				if obj_on_screen == true:
					current_ui_container.visible = true
				else:
					current_ui_container.visible = false
					
				var current_object_mesh = get_object_mesh(current_object)
				var bounding_box = get_2d_bounding_box(current_object_mesh)
				
				#this really sucks but it works for now i guess
				var child = current_ui_container.get_children()[0]
				if child.name == "rectangle":
					child.position = bounding_box.position
					child.size = bounding_box.size
				child = child.get_children()[0]
				if child.name == "item_name_bg":
					child.size.x = bounding_box.size.x
					child.visible = current_object.is_discovered
				if player.carrying == current_object:
					child = child.get_children()[0]
					if child.name == "item_name":
						child.text = str(current_object.id)
						child.visible = current_object.is_discovered
						current_object.is_discovered = true
					########


func item_entered_area(object):
	#if nodes connected and saved, return 
	for node in connected_nodes_array:
		if object == node[0]:
			return
	
	if object.is_in_group("detectable"):
		var tier_color = Color("ff5252")
		if object.tier:
			tier_color = Global.TIER_COLORS[Global.TIER_COLORS.keys()[object.tier]]
			print(tier_color)
		
		var item_name_shader_material = ShaderMaterial.new()
		item_name_shader_material.shader = negative_shader
		
		var rectangle = ReferenceRect.new()
		rectangle.name = "rectangle"
		rectangle.material = item_name_shader_material
		
		rectangle.border_color = tier_color
		rectangle.border_width = 1
		rectangle.editor_only = false
		var current_object_mesh = get_object_mesh(object)
		var bounding_box = get_2d_bounding_box(current_object_mesh)
		rectangle.position = bounding_box.position
		rectangle.size = bounding_box.size
		
		var item_name_bg = ColorRect.new()
		item_name_bg.name = "item_name_bg"
		item_name_bg.color = tier_color
		item_name_bg.size.x = bounding_box.size.x
		item_name_bg.size.y = 25
		item_name_bg.position += Vector2(0, -25)
		
		var item_name = Label.new()
		var item_name_theme = Theme.new()
		#item_name_theme.default_font = load("res://assets/RobotoMono-Italic-VariableFont_wght.ttf")
		item_name.theme = item_name_theme
		item_name.name = "item_name"
		item_name.add_theme_color_override("font_color", Color(0,0,0))
		
		
		#item_name.material = item_name_shader_material
		
		
		#item_name.clip_text = true
		if object.is_discovered == true:
			item_name.text = str(object.id)
		else:
			item_name.text = "???"
		
		var ui_container = Node2D.new()
		
		#item_name.visible = false
		#item_name_bg.visible = false
		
		rectangle.add_child(item_name_bg)
		item_name_bg.add_child(item_name)
		
		ui_container.add_child(rectangle)
		
		
		# if object doesnt have on screen notifier
		var visible_on_screen_notifier = get_on_screen_notifier(object)
		if visible_on_screen_notifier == null:
			visible_on_screen_notifier = VisibleOnScreenNotifier3D.new()
			visible_on_screen_notifier.aabb = object.mesh.get_aabb()
			object.add_child(visible_on_screen_notifier)
		
		connected_nodes_array.push_front([object, ui_container])
		
		#print(connected_nodes_array)
		add_child(ui_container)
		#print("added:   ", object)

func item_exited_area(object):
	for node in connected_nodes_array:
		if object == node[0]:
			var current_object = node[0]
			var current_ui_container = node[1]
			
			var visible_on_screen_notifier = get_on_screen_notifier(current_object)
			if visible_on_screen_notifier:
				visible_on_screen_notifier.queue_free()
			current_ui_container.queue_free()
			connected_nodes_array.erase(node)
			#print("deleted:   ", current_object)

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
	if object:
		if object.get_child_count() >= 1:
				#get mesh instance
				for child in object.get_children():
					if child is MeshInstance3D:
						return child

func get_on_screen_notifier(object):
	if object:
		if object.get_child_count() >= 1:
				#get on screen notifier
				for child in object.get_children():
					if child is VisibleOnScreenNotifier3D:
						return child
