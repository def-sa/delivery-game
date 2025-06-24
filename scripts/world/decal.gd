extends Decal

@onready var decal = $"."
@onready var decal_parent = $".."

func _process(_delta: float) -> void:
	decal.global_position.x = decal_parent.global_position.x
	decal.global_position.y = decal_parent.global_position.y - 10.5
	decal.global_position.z = decal_parent.global_position.z
	decal.global_rotation = Vector3.ZERO
