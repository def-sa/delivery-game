extends Control

@onready var module_container: HFlowContainer = $"../text_box"
@onready var chat_container: VBoxContainer = $"../text_box/chat_container"

@onready var player: CharacterBody3D = $"../../game/player"

@onready var text_edit: TextEdit = $"../text_box/chat_container/text_edit"

const TEXT_LINE = preload("res://scenes/text_line.tscn")

func type_in_chat(text):
	var text_line_node = TEXT_LINE.duplicate().instantiate()
	chat_container.add_child(text_line_node)
	text_line_node.text = text
	text_edit.release_focus()
	text_edit.move_to_front()
	text_edit.clear()

func _on_text_edit_gui_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("enter"):
		type_in_chat(str(player.name +" : "+ text_edit.text))

func _on_text_edit_text_changed() -> void:
	text_edit.text = text_edit.text.replace("\t", "")
	text_edit.text = text_edit.text.replace("\n", "")
	
	var line := text_edit.get_line_count() - 1
	text_edit.set_caret_line(line)
	text_edit.set_caret_column(text_edit.get_line(line).length())

func _on_chat_container_child_order_changed() -> void:
	if chat_container.get_child_count() == 8:
		chat_container.get_child(0).queue_free()
	
	if chat_container.get_child_count() <= 3: return
	
	for i in chat_container.get_child_count():
		chat_container.get_child(i).modulate = Color(1,1,1, clamp(((i+1)*0.35),0.17,0.85))
	
