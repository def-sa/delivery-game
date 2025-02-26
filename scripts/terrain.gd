extends Node3D

@export var chunk_scene: PackedScene
@export var chunk_size: float = 50.0
@export var view_distance: int = 6
@export var block_size: int = 12

@export var right_structures: Array[PackedScene]
var house_structure_chance:float = 0.50

@export var left_structures: Array[PackedScene]
var shop_structure_chance:float = 1

@onready var player = $"../Player"
var chunks = {}
var current_block_index: int = 0
var current_chunk_index = 0
@export var block_fog_color: Array[Color] = [Color("#7d3a31"),Color("#c4954c"),Color("#b95c49"),Color("#c98361"),Color("#cea47e"),Color("#8c8951"),Color("#b5c1af"),Color("#454a64")]
var current_fog_color_index = 0:
	set(value):
		var clamped_value = value % block_fog_color.size()
		current_fog_color_index = clamped_value
		
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
		current_block_index = -current_chunk_index % block_size
		_update_fog(current_chunk_index)
		_generate_chunks_from_index(current_chunk_index)
		_free_outside_chunks()

#BUG: fog doesnt update based on consecutive blocks entered, only new blocks. going backwards will progress fog color 
func _update_fog(current_chunk_index):
	#clamp number to size of color array
	var chunk_index_by_fog = -current_chunk_index % block_fog_color.size()
	if chunk_index_by_fog == 0: #for each new block entered
		$"../WorldEnvironment".environment.set_fog_light_color(block_fog_color[current_fog_color_index])
		current_fog_color_index = current_fog_color_index + 1

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
		
		if position != Vector3(0,0,0): #is not spawn
			if position != Vector3(-50,0,0):
				if position != Vector3(50,0,0): 
					
					chunks[position].queue_free()
					#print("/REMOVED/ chunk removed : ", position)
					chunks.erase(position)

func _create_chunk(position: Vector3):
	var chunk = chunk_scene.instantiate()
	chunk.global_transform.origin = position
	$".".add_child(chunk)
	chunks[position] = chunk
	#print("/ADDED/ chunk created : ", chunk.position)
	if position != Vector3(0,0,0): #is not spawn
			if position != Vector3(-50,0,0):
				if position != Vector3(50,0,0):
					#print("block index : ",(position.z / chunk_size) / -block_size)
					#if (position.z / chunk_size) / block_size <= -2:
						#$"../WorldEnvironment".environment.set_fog_light_color(Color("#000000"))
					if position.x > 0: #add structures to the rightmost chunk
						#add houses, debris, objectives, ect
						_create_houses(chunk, position) # 50% chance
					if position.x < 0: #add structures to the leftmost chunk
						#add shops, refill stations, abandoned warehouse, ect
						#if last chunk before new block
						if current_block_index == block_size - 1:
							_create_shops(chunk, position) # 100% chance


func _create_houses(chunk, position: Vector3):
	for i in range(0, int(randf() * 10)):
		if randf() < house_structure_chance:
			var structure = right_structures[randi() % right_structures.size()].instantiate()
			#structure.global_transform.origin = Vector3(position.x + randf_range(-chunk_size / 2, chunk_size / 2), 0, position.z + randf_range(-chunk_size / 2, chunk_size / 2))
			chunk.add_child(structure)

func _create_shops(chunk, position: Vector3):
	for i in range(0, int(randf() * 10)):
		if randf() < shop_structure_chance:
			var structure = left_structures[randi() % left_structures.size()].instantiate()
			#structure.global_transform.origin = Vector3(position.x + randf_range(-chunk_size / 2, chunk_size / 2), 0, position.z + randf_range(-chunk_size / 2, chunk_size / 2))
			chunk.add_child(structure)
