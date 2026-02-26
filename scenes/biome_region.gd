# BiomeRegionArea.gd
extends Area3D
class_name biome_region
#
#@export var noise: Noise
#@export var noise_scale: float = 10.0
#@export var noise_height_scale: float = 5.0
#@export var texture: Texture2D
#@export var texture_uv1_scale: Vector3 = Vector3(3,3,3)
#@export var subdivisions: int = 4
#
#@export var min_height_set: float = 0.05
#@export var max_height_set: float = 0
#
#var min_height:float
#var max_height:float

@export var texture: Texture2D
@export var noise: FastNoiseLite
@export var noise_scale: float = 1.0
#@export var blend_width: float = 10.0
@export var subdivisions: int = 4

@export var biome_priority := 0  # Higher means more dominant
#@export var region_center: Vector2 = Vector2.ZERO 
#@export var region_radius: float = 100.0  # Radius of influence
#@export var height_multiplier: float = 1.0  # How much this biome influences height

#@export var region_center: Vector2 = # Center of biome region
var region_size: Vector2  # Size of the biome's AABB (width, height)
@export var height_multiplier: float = 1.0  # Height influence multiplier
#@export var texture: Texture2D = null  # Optional texture for the biome

@onready var collision_shape: CollisionShape3D = $"./collision_shape_3d"

# These now come from bounds
var min_height := 0.0
var max_height := 0.0

func _ready():
	var box = collision_shape.shape as BoxShape3D
	min_height = position.y
	max_height = position.y + box.size.y
	
	region_size = calculate_region_size()
	

#func contains_point(world_pos: Vector3) -> bool:
	## convert into the collision shape's local space
	#var local = collision_shape.to_local(world_pos)
	## get half-extents in XZ
	#var box = collision_shape.shape as BoxShape3D
	#var half = box.size * 0.5
	#return abs(local.x) <= half.x and abs(local.z) <= half.z
#
#func distance_to_edge(world_pos: Vector3) -> float:
	#var local = collision_shape.to_local(world_pos)
	#var box = collision_shape.shape as BoxShape3D
	#var half = box.size * 0.5
	#var dx = half.x - abs(local.x)
	#var dz = half.z - abs(local.z)
	#return min(dx, dz)
	#

func calculate_region_size():
	if not collision_shape or not collision_shape.shape:
		print("BiomeRegion missing CollisionShape3D or shape.")
		return Vector2(0,0)

	var shape = collision_shape.shape as BoxShape3D
	var size = shape.size
	return Vector2(size.x, size.z)


#func get_height_at_world(x: float, z: float) -> float:
	#var local_pos = to_local(Vector3(x, 0, z))
	#var noise_val = noise.get_noise_2d(x * noise_scale, z * noise_scale)
	#var height_range = max_height - min_height
	#return min_height + noise_val * max_height
#
## Get the bounding box for the biome region
#func get_bounding_box(biome: Node3D) -> Rect2:
	#var collision_shape = biome.get_node("collision_shape_3d")
	#if collision_shape and collision_shape.shape is BoxShape3D:
		#var box_shape = collision_shape.shape as BoxShape3D
		#var extents = box_shape.size * 0.5  # Get half the size of the box (extents)
		#
		## Convert the center position of the biome (world position)
		#var center = biome.position
		#return Rect2(center.x - extents.x, center.z - extents.z, extents.x * 2, extents.z * 2)
	#else:
		## If no valid box shape is found, return a fallback rectangle
		#return Rect2(Vector2.ZERO, Vector2.ZERO)
