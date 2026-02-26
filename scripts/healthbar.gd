extends TextureRect


@export var health_bar: ProgressBar
@export var damage_bar: ProgressBar
@export var aspect_ratio_container: AspectRatioContainer
const CRACKED_MATERIAL = preload("res://themes/cracked_glass_material.tres")
#
#@onready var health_bar: ProgressBar = $health_bar
#@onready var damage_bar: ProgressBar = $health_bar/damage_bar

var i_frames:bool:
	set(v):
		i_frames = v
		if i_frames == true:
			await get_tree().create_timer(i_frame_time).timeout
			i_frames = false
@export var i_frame_time = 0.12

@export var health_ui_delay = 0.5


func set_box_damaged_state(health:float, box_mesh_instance:MeshInstance3D):
	if not box_mesh_instance: return

	if health <= 25:
		box_mesh_instance.material_overlay = CRACKED_MATERIAL
		box_mesh_instance.material_overlay.albedo_color = Color(1,1,1,0.235)
		return
	if health <= 50:
		box_mesh_instance.material_overlay = CRACKED_MATERIAL
		box_mesh_instance.material_overlay.albedo_color = Color(1,1,1,0.235/2)
		return
	if health <= 75:
		box_mesh_instance.material_overlay = CRACKED_MATERIAL
		box_mesh_instance.material_overlay.albedo_color = Color(1,1,1,0.235/3)
		return
	if health >= 100:
		
		return
func set_health_ui(current_health:float, new_health:float):
	
	#health added, handle damage ui
	if current_health < new_health:
		damage_bar.modulate = Color("ffffff")
		damage_bar.value = new_health
		
		create_tween().tween_property(health_bar, "value", new_health, health_ui_delay)
	
	#damage taken, handle damage ui
	if current_health > new_health:
		if i_frames == true: return
		damage_bar.modulate = Color("ff0000")
		health_bar.value = new_health
		damage_bar.value = current_health
		
		i_frames = true
		
		create_tween().tween_property(damage_bar, "value", new_health - 5, health_ui_delay)
func set_max_health(max_health:float):
	health_bar.max_value = max_health
	damage_bar.max_value = max_health
	#health_bar.value = max_health
