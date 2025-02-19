extends Node

signal fov_updated(is_default:bool, value:int)
signal sensitivity_updated(is_default:bool, value:int)
signal grab_buffer_cooldown_updated(is_default:bool, value:float)

signal grab_buffer_expired()
signal gui_cooldown()

signal settings_slider(slider_name:String, is_default:bool, value:float)
