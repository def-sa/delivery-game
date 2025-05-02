extends Control
@onready var restart_container: VBoxContainer = $requires_restart/VBoxContainer

@onready var revert_timer: Timer = $revert_changes/VBoxContainer/revert_timer
@onready var revert_changes: ColorRect = $revert_changes
@onready var reverting_in_label: Label = $revert_changes/VBoxContainer/reverting_in_label

var paused: bool = false:
	set(v):
		paused = v
		Signalbus.is_paused.emit(paused)
@onready var world: Node3D = $"../../World"
@onready var pause_menu: Control = $"."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pause_menu.hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		paused = !paused
		pause_menu.visible = paused
		world.get_tree().paused = paused
		
		if paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		elif !paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(delta: float) -> void:
	if revert_changes.visible:
		reverting_in_label.text = "reverting in "+str(int(revert_timer.time_left))+"..."

func add_to_restart_list(value:String):
	var label = Label.new()
	label.text = value
	restart_container.add_child(label)
	restart_container.visible = bool(restart_container.get_child_count() >= 2)

func remove_from_restart_list(value:String):
	for child in restart_container.get_children():
		if str(child.text).contains(value):
			child.queue_free()
	restart_container.visible = bool(restart_container.get_child_count() >= 2)

var previous_value
var current_value
var current_setting

func revert_changes_popup(value, p_value, setting_string):
	revert_timer.start()
	revert_changes.visible = true
	current_value = value
	previous_value = p_value
	current_setting = setting_string
	return true

func _on_revert_button_pressed() -> void:
	if previous_value:
		Settings[current_setting] = previous_value
	else:
		Settings[current_setting] = Settings[current_setting+"_default"]
	_disable_popup()

func _on_save_button_pressed() -> void:
	Settings[current_setting] = current_value
	_disable_popup()

func _disable_popup():
	revert_changes.visible = false
	revert_timer.stop()
	current_value = null
	previous_value = null
	current_setting = null


func _on_revert_timer_timeout() -> void:
	_on_revert_button_pressed()
