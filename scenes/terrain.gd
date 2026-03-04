extends Node3D
#@onready var player: CharacterBody3D = $"../player"
#
##@onready var csg_combiner_3d: CSGCombiner3D = $csg_combiner_3d
#@onready var csg_combiner_3d: CSGBox3D = $csg_combiner_3d
#
#
#@export var seed: String
#
#@export var chunk_scene	: PackedScene
#@export var chunk_size	 : int		  = 32
#
#@export var view_distance  : int = 4
#
#@export var texture: Texture
#@export var texture_uv1_scale: float = 3.0
#@export var noise: Noise
#@export var noise_scale	: float		= 10.0
#@export var noise_height_scale:float = 1.0
#@export var subdivisions:int = 4
#
#@export var biome_blend_width : float	 = 6.0
#
## preload your eight biome scenes
#var preset_block_scenes = {
	#1: {
		#preload("res://assets/blocks/1/sidewalk.tscn"): [
			#Vector3(15, 4, BLOCK_CHUNKS * chunk_size),
			#Vector3(-10,0,0)
			#],
		#preload("res://assets/blocks/1/biome.tscn"): [
			##size
			#Vector3(16 * chunk_size, 2.0, BLOCK_CHUNKS * chunk_size),
			##position offset
			#Vector3(0,0,0),
			#]
	#},
	#2: {}
#}
##var preset_chunk_scenes = {
	##0: preload("res://assets/blocks/sidewalk.tscn")
##}
#
#
## world‐space atlas of biome regions:
#var biome_regions : Array = []
#
## map from grid‐coords Vector2i → chunk Node3D
#var chunks := {}
#var current_block = null:
	#set(v):
		#if current_block == v: return
		#current_block = v
		##_set_biome()
#
## last center chunk so we only recalc when the player crosses a border
#var last_center := Vector2i(INF, INF)
#const BLOCK_CHUNKS = 12
#
#func _ready():
	#_set_seed(seed)
	##_update_biome_regions()
	##_generate_each_chunk()
	##_spawn_all_biomes()
	##_spawn_all_structures()
	#
	#current_block = 0
	#_update_chunks(true)  # initial fill
#
#func _set_seed(seed_name):
	#var seed_to_use : int
	#if seed_name:
		#seed_to_use = hash(seed_name)
	#else:
		#seed_to_use = randi()
	#seed(seed_to_use)
#
#func _process(_delta):
	#_update_chunks(false)
#
#func _update_chunks(override_new_chunk_step):
	#var px = int(floor(player.global_position.x / chunk_size))
	#var pz = int(floor(player.global_position.z / chunk_size))
	#current_block = -int(floor(pz / BLOCK_CHUNKS))
	#var center = Vector2i(px, pz)
#
	## Only rebuild when you actually step into a new chunk
	#if center == last_center and not override_new_chunk_step:
		#return
	#last_center = center
#
	## build WANT set
	#var want = {}
	#for dz in range(-view_distance - 1, view_distance + 1):
		#for dx in range(-view_distance - 1, view_distance + 1):
			#want[Vector2i(px+dx, pz+dz)] = true
	#
	## spawn missing
	#for coord in want.keys():
		#if not chunks.has(coord):
			#_spawn_chunk(coord)
	#
	## free extras
	#for coord in chunks.keys():
		#if not want.has(coord):
			#if chunks[coord]:
				#chunks[coord].queue_free()
				#chunks.erase(coord)
#
#func _update_biome_regions():
	## collect all your BiomeRegion3D children
	#for node in get_children():
		#if node is biome_region:
			#biome_regions.push_back(node)
#
#func _spawn_chunk(coord: Vector2i):
	## instantiate and hook up
	#var chunk = chunk_scene.instantiate() as Node3D
	#chunk.texture = texture
	#chunk.texture_uv1_scale = texture_uv1_scale
	#chunk.noise = noise
	#chunk.chunk_coords	   = coord
	#chunk.chunk_size		 = chunk_size
	#chunk.noise_scale		= noise_scale
	#chunk.noise_height_scale = noise_height_scale
	##chunk.biome_regions	  = biome_regions
	#chunk.biome_blend_width  = biome_blend_width
	#chunk.subdivisions = subdivisions
	##chunk.csg_combiner = csg_combiner_3d
	#
	#
	## position in world‐space
	#var world_pos = Vector3(coord.x * chunk_size, 0, coord.y * chunk_size)
	#add_child(chunk)
	#
	###CHECK IF CSG BOXES ARE INTERSECTING. WAIT TO FINISH, THEN ALLOW CSG BOXES TO GENERATE IN ALL CHUNKS 
	#
	#chunk.global_transform.origin = world_pos
	#chunks[coord] = chunk
	##return chunk
#
##
##func _spawn_chunk_areas(area_scene:biome_region, size:Vector3, block_z):
	##print("chunk area: ",area_scene, size, block_z)
	##for i in BLOCK_CHUNKS:
		##var cs	 = area_scene.get_child(0).shape as BoxShape3D
		##cs.size	= size
##
		### position: fixed X, and Z = band index × band size + half-band
		##area_scene.position = Vector3(
			##0 * chunk_size,
			##0,
			##-i * size.z + (size.z/2)
		##)
##
		##add_child(area_scene)
		##biome_regions.append(area_scene)
##
##func _generate_each_chunk():
	##pass
##func _spawn_all_structures():
	##pass
##
##
##func _spawn_all_biomes() -> void:
	###world border
	##for x in range(0,32):
		##var WORLD_BORDER = preload("res://scenes/world_border.tscn").instantiate()
		##_spawn_block_areas(WORLD_BORDER, Vector3(35, 256.0, BLOCK_CHUNKS * chunk_size), x + 1, Vector3(-256,0,0))
	##for y in range(0,32):
		##var WORLD_BORDER = preload("res://scenes/world_border.tscn").instantiate()
		##_spawn_block_areas(WORLD_BORDER, Vector3(35, 256.0, BLOCK_CHUNKS * chunk_size), y + 1, Vector3(256,0,0))
	##
	##
	### for each preset
	##var i = 0
	##for block_z in preset_block_scenes.keys():
		##if i == 1: break
		##i += 1
		##var scene_dict = preset_block_scenes[block_z]
		##
		### Now iterate through each PackedScene in this biome
		##for packed_scene in scene_dict.keys():
			##var config = scene_dict[packed_scene]
			##var size = config[0]
			##var offset = config[1]
			##
			### Instantiate the scene
			##var region = packed_scene.instantiate()
			##print("spawning ", region, size, offset)
			### Call your helper to fill/spawn areas
			##_spawn_block_areas(region, size, block_z + 1, offset)
##
##
##
##func _spawn_block_areas(area_scene, size:Vector3, block_z, position_offset):
	##print("block area: ",area_scene, size, block_z)
	##
	##var cs	 = area_scene.get_child(0).shape as BoxShape3D
	##cs.size	= size
##
	### position: fixed X, and Z = band index × band size + half-band
	##area_scene.position = Vector3(
		##0 * chunk_size,
		##0,
		##-block_z * size.z + (size.z/2)
	##) + position_offset
##
	##add_child(area_scene)
	##biome_regions.append(area_scene)
##
##
##
####
####func _spawn_all_biomes() -> void:
	####for block_z in range(8):
		####print("8 loop")
		####if preset_block_scenes.has(block_z):
			####var dict = preset_block_scenes[block_z]
			####for scene in preset_block_scenes.keys():
				####print(scene)
				####var array = dict[scene]
				####var region = scene.duplicate().instantiate()
				####var size = array[0]
				####var position_offset = array[1]
				####
				####_spawn_block_areas(region, size, block_z+ 1, position_offset) # + 1 for offset 
#####
####func _spawn_all_sidwalks() -> void:
	####for block_z in range(8):
		####if preset_block_scenes.has(block_z):
			####var region = preset_block_scenes[block_z].duplicate().instantiate()
			####var size = Vector3(16 * chunk_size, 5.0, BLOCK_CHUNKS * chunk_size)
			####_spawn_block_areas(region, size, block_z)
###
####func _spawn_all_sidewalks():
	####
	####for block_z in range(8):
		####print("chunk 8 loop")
		####if preset_chunk_scenes.has(block_z):
			####var region = preset_chunk_scenes[block_z].duplicate().instantiate()
			####var size = Vector3(chunk_size,5,chunk_size)
			####_spawn_block_areas(region, size, block_z)
	####pass
##
