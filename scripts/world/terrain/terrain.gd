extends Node3D

@export var seed_name: String = "cvyjiubo7jgy9trjytdihgltk9 h80j9y7utrm9bliu"

@export var chunk_scene: PackedScene
@export var chunk_size: float = 50.0
@onready var view_distance: int = Settings.render_distance
@export var block_size: int = 12
#@export var right_structures: Array[PackedScene]
var house_structure_chance:float = 0.5
#@export var left_structures: Array[PackedScene]
var shop_structure_chance:float = 1

@onready var player: CharacterBody3D = $"../World/Player"

var chunks = {}

var current_block_index: int = 0
var current_chunk_index: int = 0
var initial = null


#TODO: when creating chunks, would it be more efficient to use multithreading? idk how that workz
func _ready():
	var seed_to_use : int
	
	if seed_name:
		seed_to_use = hash(seed_name)
	else:
		seed_to_use = randi()
	
	seed(seed_to_use)
	
	Signalbus.render_distance_updated.connect(_render_distance_updated)
	initial = true
	_generate_initial_chunks()

func _process(delta):
	_update_chunks()

func _generate_initial_chunks():
	for i in range(-view_distance, view_distance):
		for j in range(-1, 2):  # Create three lanes (-1, 0, 1)
			var z = -i * chunk_size
			var x = j * chunk_size
			_create_chunk(Vector3(x, 0, z), 1)
	initial = false

func _update_chunks():
	var player_z = player.global_transform.origin.z
	var new_chunk_index = int(player_z / chunk_size)
	if new_chunk_index != current_chunk_index:
		current_chunk_index = new_chunk_index
		current_block_index = -current_chunk_index % block_size
		#print("BLOCK: in chunk (", current_block_index, " of ", block_size, ")")
		_generate_chunks_from_index(current_chunk_index)
		_free_outside_chunks(current_chunk_index)

func _generate_chunks_from_index(index):
		for i in range(-view_distance, view_distance):
			for j in range(-5, 5):  # Update three lanes
				var z = (index - i) * chunk_size
				var x = j * chunk_size
				var chunk_position = Vector3(x, 0, z)
				if chunk_position not in chunks:
					_create_chunk(chunk_position, index)

#TODO: free from index not setup 
func _free_outside_chunks(index):
	var positions_to_remove = []
	var player_z = player.global_transform.origin.z
	for _position in chunks.keys():
		if abs(_position.z - player_z) > view_distance * chunk_size:
			positions_to_remove.append(_position)
	for _position in positions_to_remove:
		for chunk in chunks.keys():
			if chunk == _position:
				chunks[chunk].queue_free()
				print("/REMOVED/ chunk removed : ", chunks[chunk])
				chunks.erase(chunk)

func _create_chunk(position: Vector3, index):
	var chunk = chunk_scene.instantiate()
	chunk.position = position
	chunks[position] = chunk
	add_child(chunk)
	#print(chunk.name)
	
	#if not spawn chunk
	if index != 0:
		if position.x > 0: #add structures to the rightmost chunk
			#add houses, debris, objectives, ect
			_create_structure("house", chunk, house_structure_chance, index)
		if position.x < 0: #add structures to the leftmost chunk
			#add shops, refill stations, abandoned warehouse, ect
			
			#if last chunk before new block
			if current_block_index == block_size - 1:
				#shop
				_create_structure("shop", chunk, shop_structure_chance, index)


func _create_structure(type, chunk, chance, index):
	for i in range(0, int(randf() * 10)):
		if randf() < chance:
			#don't generate if structure already found
			for child in chunk.get_children():
				if child.name == "structure":
					print("structure found in chunk already, returning", chunk.position)
					return
			print("creating structure", chunk.position)
			
			#var dungeon = DungeonGenerator3D.new()
			#dungeon.voxel_scale = Vector3(5,5,5)
			#dungeon.name = "structure"
			
			match type:
				"house":
					pass
					#print("creating house")
					#_create_house(chunk, dungeon)
				"shop":
					pass
					#print("creating shop")
					#_create_shop(chunk, dungeon)



func get_node_with_group_spawner(node):
	if node is Node and node != null:
		if node.is_inside_tree():
			for child in node.get_children():
				if child.is_in_group("spawner"):
					return child
	return null



#settings slider changed
func _render_distance_updated(value):
	view_distance = value
	var player_z = player.global_transform.origin.z
	var new_chunk_index = int(player_z / chunk_size)
	_generate_chunks_from_index(new_chunk_index)
	_free_outside_chunks(new_chunk_index)
