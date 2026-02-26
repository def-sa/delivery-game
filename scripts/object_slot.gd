extends MeshInstance3D
class_name physics_slot

@export var is_delivery_point = false
@export var is_slot = false
@export var is_cart_slot = false

var slot_reenter:bool:
	set(v):
		slot_reenter = v
		if slot_reenter == true:
			await get_tree().create_timer(slot_reenter_cooldown).timeout
			slot_reenter = false
@export var slot_reenter_cooldown:float = 0.25


var object_in_slot:
	set(v):
		object_in_slot = v
		print(object_in_slot)

func _on_slot_entered(body: Node3D) -> void:
	if slot_reenter == true: return
	if body == object_in_slot: 
		slot_reenter = true
		return
	if not body: return
	if not body is physics_item: return
	object_in_slot = body
	
	mesh.material.albedo_color = Color("00ffff0a")
	
	if is_delivery_point and object_in_slot.is_in_group("deliverable"):
		object_in_slot.box_state = object_in_slot.BOX_STATES.DELIVERED
	if is_cart_slot and object_in_slot.box_overlay.overlay_state == object_in_slot.box_overlay.OVERLAY_STATES.UNDETECTED:
		object_in_slot.box_state = object_in_slot.BOX_STATES.ON_CART
	

func _process(delta: float) -> void:
	if slot_reenter == true: return
	if not object_in_slot: return
	if not object_in_slot is physics_item: return
	
	if object_in_slot and object_in_slot.box_state == object_in_slot.BOX_STATES.ON_CART:
		return
	
	if is_cart_slot and not object_in_slot.box_overlay.overlay_state == object_in_slot.box_overlay.OVERLAY_STATES.HELD:
		#print(object_in_slot)
		object_in_slot.linear_velocity = Vector3.ZERO
		
		create_tween().tween_property(object_in_slot, "global_position", global_position, 40 * delta)


func _drop_object(item_in_slot):
	
	mesh.material.albedo_color = Color("ffffff0a")
	if item_in_slot == object_in_slot:
		object_in_slot = null
		if not item_in_slot: return
		if not item_in_slot is physics_item: return
		item_in_slot.box_state = item_in_slot.BOX_STATES.IDLE

func _on_slot_exited(body: Node3D) -> void:
	_drop_object(body)
	#var object_vars = _is_valid_physics_item(object_in_slot)
	#if not object_vars: return
	#
	#mesh.material.albedo_color = Color("ffffff0a")
	#if body == object_in_slot:
		#object_in_slot = null
		#object_vars.box_state = object_vars.BOX_STATES.IDLE
