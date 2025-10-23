extends Control

@onready var slider: HSlider = $Backspin_Info/HSlider
@onready var label: Label = $Backspin_Info/Backspin_Label
@onready var camera_pivot: Node3D = $"../CameraPivot"
var rifle: Area3D
var shotgun: Area3D
var pistol: Area3D

@export var scroll_speed := 0.005

func _ready():
	label.text = str(slider.value * 10)

func _process(_delta):

	label.text = str(slider.value * 10)

func _on_h_slider_value_changed(value: float) -> void:
	label.text = str(value * 10)
	
	for camera in camera_pivot.get_children():
		for child in camera.get_children():
			if child is Area3D:
				if child.has_method("set") or "backspin" in child:
					child.backspin = value


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			slider.value = clamp(slider.value + scroll_speed, slider.min_value, slider.max_value)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			slider.value = clamp(slider.value - scroll_speed, slider.min_value, slider.max_value)
