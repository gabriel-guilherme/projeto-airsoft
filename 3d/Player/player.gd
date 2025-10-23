extends CharacterBody3D

var speed = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.002

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var control: Control = $UI

@onready var rifle: Node3D = $CameraPivot/Camera3D/Rifle
@onready var shotgun: Node3D = $CameraPivot/Camera3D/Shotgun
@onready var pistol_1911: Node3D = $CameraPivot/Camera3D/Pistol_1911
@onready var pistol_glock: Node3D = $CameraPivot/Camera3D/Pistol_Glock

var current_weapon: Node3D = null

var yaw := 0.0
var pitch := 0.0


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	switch_weapon(1)

	if control.has_node("HSlider"):
		var slider = control.get_node("HSlider")
		slider.connect("value_changed", Callable(self, "_on_backspin_slider_changed"))


func _input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * MOUSE_SENSITIVITY
		pitch -= event.relative.y * MOUSE_SENSITIVITY
		pitch = clamp(pitch, deg_to_rad(-90), deg_to_rad(90))
		rotation.y = yaw
		camera_pivot.rotation.x = pitch

	if event.is_action_pressed("weapon_1"):
		switch_weapon(1)
	elif event.is_action_pressed("weapon_2"):
		switch_weapon(2)
	elif event.is_action_pressed("weapon_3"):
		switch_weapon(3)
	elif event.is_action_pressed("weapon_4"):
		switch_weapon(4)
		
	if event.is_action_pressed("sprint"):
		speed = 15
	elif event.is_action_released("sprint"):
		speed = 5


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	#if Input.is_action_just_pressed("jump") and is_on_floor():
	#	velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var forward = transform.basis.z
	var right = transform.basis.x
	var direction = (forward * input_dir.y + right * input_dir.x).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()


func switch_weapon(slot: int) -> void:

	match slot:
		1:
			if current_weapon == rifle:
				return
			current_weapon = rifle
		2:
			if current_weapon == shotgun:
				return
			current_weapon = shotgun
		3:
			if current_weapon == pistol_1911:
				return
			current_weapon = pistol_1911
		4:
			if current_weapon == pistol_glock:
				return
			current_weapon = pistol_glock
		_:
			current_weapon = null
			return

	for weapon in [rifle, shotgun, pistol_1911, pistol_glock]:
		if weapon:
			weapon.visible = false
			weapon.set_process(false)
			weapon.set_physics_process(false)

	if current_weapon:
		if control.firerate_bar:
			control.switch_bar()
		current_weapon.visible = true
		current_weapon.reload_id += 1
		current_weapon.cancel_reload()
		current_weapon.set_process(true)
		current_weapon.set_physics_process(true)
		current_weapon.update_weapon_ui()





func _on_backspin_slider_changed() -> void:
	if current_weapon:
		current_weapon.update_weapon_ui()
