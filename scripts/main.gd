extends Node3D

@onready var ray_interaction = $Player/camera_pivot/spring_arm_3d/camera/ray_interaction
@onready var player_hand = $Player/camera_pivot/spring_arm_3d/camera/hand


var last_obj_hovered: RigidBody3D
var holding_object:bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#handle object outline & holding objects
	var object = ray_find_obj()
	
	if object != null:
		object.outline_visible = true
		last_obj_hovered = object
		
		if holding_object == true:
			object.global_position = player_hand.global_position
	else:
		if last_obj_hovered:
			last_obj_hovered.outline_visible = false


#raycast that returns whatever RigidBody3d it collides with
func ray_find_obj():
	var collider = ray_interaction.get_collider()
	if collider and collider is RigidBody3D:
		return collider

func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("lmb"):
		var object = ray_find_obj()
		if object != null and object.outline_visible == true:
			holding_object = true
		else:
			holding_object = false
	
