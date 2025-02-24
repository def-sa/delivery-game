extends Node3D

@export var chunk_scene: PackedScene
@export var chunk_size: float = 50.0
@export var view_distance: int = 3
@export var structure_scenes: Array[PackedScene]
@export var structure_chance: float = 0.5

@onready var player = $"../Player"
var chunks = {}
var current_chunk_index = 0
func _ready():
	_generate_initial_chunks()

func _process(delta):
	_update_chunks()

func _generate_initial_chunks():
	for i in range(view_distance):
		for j in range(-1, 2):  # Create three lanes (-1, 0, 1)
			var z = -i * chunk_size
			var x = j * chunk_size
			_create_chunk(Vector3(x, 0, z))

func _update_chunks():
	var player_z = player.global_transform.origin.z
	var new_chunk_index = int(player_z / chunk_size)
	if new_chunk_index != current_chunk_index:
		current_chunk_index = new_chunk_index
		_generate_chunks_from_index(current_chunk_index)
		_free_outside_chunks()

func _generate_chunks_from_index(index):
	for i in range(view_distance):
		for j in range(-1, 2):  # Update three lanes
			var z = (index - i) * chunk_size
			var x = j * chunk_size
			var chunk_position = Vector3(x, 0, z)
			if chunk_position not in chunks:
				_create_chunk(chunk_position)

func _free_outside_chunks():
	var positions_to_remove = []
	var player_z = player.global_transform.origin.z
	for position in chunks.keys():
		if abs(position.z - player_z) > view_distance * chunk_size:
			positions_to_remove.append(position)
	for position in positions_to_remove:
		chunks[position].queue_free()
		print("/REMOVED/ chunk removed : ", position)
		chunks.erase(position)

func _create_chunk(position: Vector3):
	var chunk = chunk_scene.instantiate()
	chunk.global_transform.origin = position
	$".".add_child(chunk)
	chunks[position] = chunk
	print("/ADDED/ chunk created : ", chunk.position)
	
	#add structures to the rightmost chunk
	if position.x > 0:
		#print("Spawning Structures in Chunk: ", position)
		for i in range(0, int(randf() * 10)):
			if randf() < structure_chance:
				var structure = structure_scenes[randi() % structure_scenes.size()].instantiate()
				#structure.global_transform.origin = Vector3(position.x + randf_range(-chunk_size / 2, chunk_size / 2), 0, position.z + randf_range(-chunk_size / 2, chunk_size / 2))
				chunk.add_child(structure)
				#print("Structure Spawned at: ", structure.global_transform.origin)
