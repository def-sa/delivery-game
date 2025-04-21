extends Node3D

var seed_name: String = "wasgajahhjfukfhkfhkyfujk"

@export var chunk_scene: PackedScene
@export var chunk_size: float = 50.0
@export var view_distance: int = Settings.render_distance_default
@export var block_size: int = 12
@export var room_scenes : Array[PackedScene] = []
#@export var house_size := Vector3i(1,2,1)
#@export var shop_size := Vector3i(2,2,2)
#@export var right_structures: Array[PackedScene]
var house_structure_chance:float = 0.5
#@export var left_structures: Array[PackedScene]
var shop_structure_chance:float = 1

@onready var player: CharacterBody3D = $"../Player"

var chunks = {}

var current_block_index: int = 0
var current_chunk_index: int = 0
var initial = null


func _ready():
	_set_seed(seed_name)
	
	Signalbus.render_distance_updated.connect(_render_distance_updated)
	initial = true
	_generate_initial_chunks()

func _set_seed(seed_name):
	var seed_to_use : int
	if seed_name:
		seed_to_use = hash(seed_name)
	else:
		seed_to_use = randi()
	seed(seed_to_use)

func _process(delta):
	_update_chunks()

func _generate_initial_chunks():
	for i in range(-view_distance, view_distance):
		for j in range(-2, 3):  # Create three lanes (-1, 0, 1)
			var z = -i * chunk_size
			var x = j * chunk_size
			_create_chunk(Vector3(x, 0, z), 1)
	initial = false

func _update_chunks():
	var player_z = player.global_transform.origin.z
	var new_chunk_index = int(player_z / chunk_size)
	if new_chunk_index != current_chunk_index:
		current_chunk_index = new_chunk_index
		var block_index = -int(floor(float(current_chunk_index) / block_size))
		var chunk_in_block = -current_chunk_index % block_size
		if chunk_in_block < 0:
			chunk_in_block += block_size
		print("/UPDATED/: block #", block_index, " (", chunk_in_block, "/", block_size,")")
		
		_generate_chunks_from_index(current_chunk_index)
		_free_outside_chunks()

func _generate_chunks_from_index(index):
		for i in range(-view_distance, view_distance):
			for j in range(-1, 2):  # Update three lanes
				var z = (index - i) * chunk_size
				var x = j * chunk_size
				var chunk_position = Vector3(x, 0, z)
				if chunk_position not in chunks:
					_create_chunk(chunk_position, index)

func _free_outside_chunks():
	var positions_to_remove = []
	var player_z = player.global_transform.origin.z
	for position in chunks.keys():
		if abs(position.z - player_z) > view_distance * chunk_size:
			positions_to_remove.append(position)
	for pos in positions_to_remove:
		if chunks.has(pos):  # Safety check in case it was already removed
			chunks[pos].queue_free()
			chunks.erase(pos)
			print("/REMOVED/ chunk removed: ", pos)

func _create_chunk(position: Vector3, index):
	var chunk = chunk_scene.instantiate()
	chunk.position = position
	chunks[position] = chunk
	add_child(chunk)
	#print(chunk.name)

#settings slider changed
func _render_distance_updated(value):
	view_distance = value
	var player_z = player.global_transform.origin.z
	var new_chunk_index = int(player_z / chunk_size)
	_generate_chunks_from_index(new_chunk_index)
	_free_outside_chunks()
