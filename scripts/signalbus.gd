extends Node

##Display Settings
signal settings_slider(slider_name:String, is_default:bool, value:float)
signal fov_updated(is_default:bool, value:int)
signal brightness_updated(is_default:bool, value:float)
signal contrast_updated(is_default:bool, value:float)
signal saturation_updated(is_default:bool, value:float)


##Control Settings
signal sensitivity_updated(is_default:bool, value:int)

##Gameplay Settings
signal render_distance_updated(is_default:bool, value:float)

##Debug Settings
signal player_speed_updated(is_default:bool, value:int)
signal player_jump_updated(is_default:bool, value:float)
signal grab_buffer_cooldown_updated(is_default:bool, value:float)
signal grab_buffer_expired()
signal max_grab_length_updated(is_default:bool, value:float)


##//
signal gui_cooldown()
signal box_being_carried(obj)
