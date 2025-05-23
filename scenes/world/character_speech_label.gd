extends RichTextLabel
#
#@onready var timer: Timer = $Timer
#@onready var in_dialogue:bool = false:
	#set(v):
		#in_dialogue = v
		#npc_name.visible = in_dialogue
		#
#
#@onready var pause_menu: Control = $"../../pause_menu"
#@onready var npc_name: RichTextLabel = $".."
#
#
#func set_dialogue(name):
	#timer.start()
	#if name:
		#npc_name.text = String(name)
		#text = "[wave amp=50.0 freq=5.0]" + String(Global.dialogues[name].pick_random()) + "[/wave]"
#
#func _process(delta: float) -> void:
	#if timer.time_left > 0:
		#visible_ratio = 1.0 - timer.time_left
#
#func set_speech_text(new_text: String):
	#text = new_text
	#visible_ratio = 0
	#timer.start()
#
#func _on_timer_timeout() -> void:
	#timer.stop()
	#visible_ratio = 1
