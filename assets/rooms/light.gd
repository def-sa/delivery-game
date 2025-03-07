extends CSGBox3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass


func _on_box_spawner_visibility_changed() -> void:
	$box_spawner.spawn_box()
