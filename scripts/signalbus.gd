extends Node
signal is_paused(value:bool)

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
