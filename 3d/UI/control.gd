extends Control

@onready var backspin_info: VBoxContainer = $Backspin_Info
@onready var firerate_info: VBoxContainer = $Firerate_Info
@onready var slider: VSlider = $Backspin_Info/HSlider
@onready var backspin_slider: VSlider = $Backspin_Info/HSlider
@onready var firerate_slider: VSlider = $Firerate_Info/HSlider
@onready var backspin_label: Label = $Backspin_Info/HSlider/Backspin_Label
@onready var firerate_label: Label = $Firerate_Info/HSlider/Firerate_Label
@onready var camera_pivot: Node3D = $"../CameraPivot"
var rifle: Area3D
var shotgun: Area3D
var pistol: Area3D

@export var backspin_scroll_speed := 0.005
@export var firerate_scroll_speed := 0.5
var scroll_speed := backspin_scroll_speed

var firerate_bar = false

func _ready():
	backspin_label.text = str(slider.value * 10)
	firerate_info.modulate = Color(1, 1, 1, .3)

func _process(_delta):
	pass
	#backspin_label.text = str(slider.value * 10)

func _on_h_slider_value_changed(value: float) -> void:
	backspin_label.text = str(value * 10)
	
	for camera in camera_pivot.get_children():
		for child in camera.get_children():
			if child is Area3D:
				if "backspin" in child:
					child.backspin = value

func switch_bar():
	firerate_bar = not firerate_bar
	if firerate_bar:
		firerate_info.modulate = Color(1, 1, 1, 1)
		backspin_info.modulate = Color(1, 1, 1, 0.3)
		
		slider = firerate_slider
		scroll_speed = firerate_scroll_speed
	else:
		firerate_info.modulate = Color(1, 1, 1, 0.3)
		backspin_info.modulate = Color(1, 1, 1, 1)
		
		slider = backspin_slider
		scroll_speed = backspin_scroll_speed

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			slider.value = clamp(slider.value + scroll_speed, slider.min_value, slider.max_value)
			#print(slider.value)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			slider.value = clamp(slider.value - scroll_speed, slider.min_value, slider.max_value)
			#print(slider.value)


func _on_firerate_value_changed(value: float) -> void:
	firerate_label.text = str(value) + " BB/s"
	
	for camera in camera_pivot.get_children():
		for child in camera.get_children():
			if child is Area3D and child.gun_modes.size() > 0:
				if "fire_rate" in child:
					child.fire_rate = value
