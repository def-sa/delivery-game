extends CSGBox3D
@onready var csg_combiner_3d: CSGBox3D = $"."

func _ready():
	csg_combiner_3d.rebuild()
