extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if not body.get_parent() is physics_item: return
	if not body.is_in_group("DELIVERABLE"): return
	
	Global.score += 10
	body.get_parent().break_box()
