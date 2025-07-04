extends Node
signal is_paused(value:bool)
signal is_interact_pressed(object)

#signal settings_slider(slider_name:String, is_default:bool, value:float)
#signal settings_dropdown(dropdown_name:String, is_default:bool, value:String)

##Display Settings
signal window_display_type_updated(value:String)
signal vsync_mode_updated(value:String)
signal shadow_quality_updated(value:String)
signal fov_updated(value:int)
signal show_fps_updated(value:bool)
signal max_fps_updated(value:int)
signal viewport_width_updated(value:int)
signal viewport_height_updated(value:int)
signal brightness_updated(value:float)
signal contrast_updated(value:float)
signal saturation_updated(value:float)

signal occlusion_culling_updated(value:String)
signal texture_filter_updated(value: String)
signal reflections_updated(value: String)


signal bilinear_filtering_updated(value: bool)

signal screen_space_reflections_updated(value: bool)
signal screen_space_ambient_occlusion_updated(value: bool)
signal screen_space_indirect_lighting_updated(value: bool)
signal sdfgi_updated(value: bool)
signal scanner_flashing_updated(value: bool)



##Control Settings
signal sensitivity_updated(value:int)

##Gameplay Settings
signal render_distance_updated(value:float)

##Audio Settings
signal main_volume_updated(value:int)

##Debug Settings
signal player_speed_updated(value:int)
signal player_jump_updated(value:float)
signal grab_buffer_updated(value:float)
signal grab_buffer_expired()
signal max_grab_length_updated(value:float)
signal box_open_timer_updated(value:float)
signal box_open_timer_expired()




##//
#signal box_being_carried(obj)
