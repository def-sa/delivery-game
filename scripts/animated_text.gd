extends Control


@export var animated_text: Control
@export var rich_text_label: RichTextLabel
@export var animation_player: AnimationPlayer
@export var check_button: Button
@onready var text_backgroubd_anim: RichTextLabel = $text_backgroubd_anim

signal button_selected(text)

func _ready() -> void:
	check_button.grab_focus()
	check_button.pressed.connect(_on_check_button_pressed)
	rich_text_label.text = self.name
	text_backgroubd_anim.text = gen_unique_string(self.name.length())

func play_animation():
	animation_player.play("text_animation")

func _on_check_button_pressed() -> void:
	print(self.name + "pressed")
	emit_signal("button_selected", self)



var ascii_letters_and_digits = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
func gen_unique_string(length: int) -> String:
	var result = ""
	for i in range(length):
		result += ascii_letters_and_digits[randi() % ascii_letters_and_digits.length()]
	return result
