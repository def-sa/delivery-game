extends Control

@onready var player: CharacterBody3D = $"../.."

@onready var camera: Camera3D = $SubViewportContainer/SubViewport/item_overlay_camera
@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport
@onready var item_container: Node3D = $SubViewportContainer/SubViewport/item_overlay_camera/item_container

@onready var id_label: Label = $item_info/id
@onready var modifiers_label: Label = $item_info/modifiers

var current_obj
var current_visiblity
var duplicated_current_obj

func _physics_process(_delta: float) -> void:
	if duplicated_current_obj:
		if player.spin_locked:
				duplicated_current_obj.set_angular_velocity(Vector3(-1,-1,-1))
		else:
			if player.carrying_obj:
				duplicated_current_obj.rotation = player.carrying_obj.rotation

func set_to(obj, visiblity):
	#print(obj, visiblity)
	if current_obj == obj and current_visiblity == visiblity: return
	if visiblity == "off":
		current_obj = null
		visible = false
		return
	visible = true
	current_visiblity = visiblity
	current_obj = obj
	remove()
	if current_obj:
		duplicated_current_obj = current_obj.duplicate()
		
		#set scale
		duplicated_current_obj.scale = current_obj.scale / 2
			
		#set modifier text
		var modifiers_string = ""
		for group in current_obj.get_groups():
			modifiers_string += str(group).capitalize()+", "
		modifiers_label.text = modifiers_string
		
		
		if "id" in current_obj:
			id_label.text = str(current_obj.id)
		#spin
		#duplicated_current_obj.set_angular_velocity(Vector3(-1,-1,-1))
		duplicated_current_obj.gravity_scale = 0
		
		if visiblity == "hovering":
			modulate = "ffffff80" #50% opacity
		else:
			modulate = "ffffff" #100% opacity
			
		
		
		##remove all scripts & groups
		for child in duplicated_current_obj.get_children():
			child.set_script(null)
		for group in duplicated_current_obj.get_groups():
			duplicated_current_obj.remove_from_group(group)
			
		item_container.add_child(duplicated_current_obj)
		duplicated_current_obj.set_linear_velocity(Vector3(0,0,0))
		duplicated_current_obj.set_angular_velocity(Vector3(0,0,0))
		duplicated_current_obj.global_position = item_container.global_position
		#camera.look_at(duplicated_current_obj.position)

func remove():
	for child in item_container.get_children():
		child.queue_free()
