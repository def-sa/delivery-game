extends Node
signal settings_slider(slider_name:String, is_default:bool, value:float)


##Display Settings
signal fov_updated(value:int)
signal brightness_updated(value:float)
signal contrast_updated(value:float)
signal saturation_updated(value:float)


##Control Settings
signal sensitivity_updated(value:int)

##Gameplay Settings
signal render_distance_updated(value:float)

##Debug Settings
signal player_speed_updated(value:int)
signal player_jump_updated(value:float)
signal grab_buffer_updated(value:float)
signal grab_buffer_expired()
signal max_grab_length_updated(value:float)
signal box_open_timer_updated(value:float)
signal box_open_timer_expired()




##//
signal gui_cooldown()
signal box_being_carried(obj)
