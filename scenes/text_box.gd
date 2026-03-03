extends HFlowContainer

@export var module_container: HFlowContainer
@export var chat_container: VBoxContainer
@export var player: CharacterBody3D
@export var text_box: HFlowContainer

const TEXT_LINE = preload("res://scenes/text_line.tscn")


#text box ____________
func type_in_chat(text):
	var text_line_node = TEXT_LINE.duplicate().instantiate()
	chat_container.add_child(text_line_node)
	text_line_node.text = text
	text_box.release_focus()
	text_box.move_to_front()
	text_box.clear()
func _on_text_edit_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("enter"):
		type_in_chat(str(player.name +" : "+ text_box.text))

func _on_text_edit_text_changed() -> void:
	text_box.text = text_box.text.replace("\t", "")
	text_box.text = text_box.text.replace("\n", "")
	var line := text_box.get_line_count() - 1
	text_box.set_caret_line(line)
	text_box.set_caret_column(text_box.get_line(line).length())

func _on_chat_container_child_order_changed() -> void:
	if chat_container.get_child_count() == 8:
		chat_container.get_child(0).queue_free()
	
	if chat_container.get_child_count() <= 3: return
	
	for i in chat_container.get_child_count():
		chat_container.get_child(i).modulate = Color(1,1,1, clamp(((i+1)*0.35),0.17,0.85))
