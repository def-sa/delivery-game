extends TabBar

func _ready() -> void:
	init_fov()
	init_sensitivity()

@onready var fov_label :Label = $VBoxContainer/FOV/slider_label
@onready var fov_slider :Slider = $VBoxContainer/FOV/fov_slider
@onready var fov_slider_value_txt :Label = $VBoxContainer/FOV/slider_value

func init_fov():
	fov_label.text = fov_slider.get_parent().get_name() + str(": ")
	update_fov_display()
	#connect signal
	fov_slider.value_changed.connect(_fov_slider_changed)

func _fov_slider_changed(value: float) -> void:
	update_fov_display()
	#relay the signal
	Signalbus.fov_updated.emit(false, int(value))

func _fov_default_pressed() -> void:
	Signalbus.fov_updated.emit(true,0)
	update_fov_display()
	
func update_fov_display():
	fov_slider_value_txt.text = str(Settings.camera_fov)
	fov_slider.value = Settings.camera_fov
	
	
@onready var sens_label :Label = $VBoxContainer/Sensitivity/sens_label
@onready var sens_slider :Slider = $VBoxContainer/Sensitivity/sens_slider
@onready var sens_slider_value_txt :Label = $VBoxContainer/Sensitivity/sens_value

func init_sensitivity():
	sens_label.text = sens_slider.get_parent().get_name() + str(": ")
	update_sensitivity_display()
	#connect signal
	sens_slider.value_changed.connect(_sensitivity_slider_changed)
	
func _sensitivity_slider_changed(value: float) -> void:
	sens_slider_value_txt.text = str(value)#relay the signal
	Signalbus.sensitivity_updated.emit(false, int(value))
	update_sensitivity_display()
	
func _sensitivity_default_pressed() -> void:
	Signalbus.sensitivity_updated.emit(true,0)
	update_sensitivity_display()
	
func update_sensitivity_display():
	sens_slider_value_txt.text = str(Settings.sensitivity)
	sens_slider.value = Settings.sensitivity
	
