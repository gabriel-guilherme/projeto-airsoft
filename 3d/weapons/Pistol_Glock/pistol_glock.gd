extends Gun

@export var pellets := 6
@export var spread_angle := 10.0
@export var sub_energy := 0.0001
@export var burst_count := 3
@export var burst_delay := 0.1
var is_bursting = false

func _process(_delta: float) -> void:
	if mode:
		if Input.is_action_just_pressed("Fire") and not reloading and not is_bursting:
			shoot_burst()
	else:
		if Input.is_action_just_pressed("Fire") and not reloading:
			shoot()
	
	if Input.is_action_pressed("energy_up"):
		change_energy(0.005)
	
	if Input.is_action_pressed("energy_down"):
		change_energy(-0.005)
		
	if Input.is_action_just_pressed("Reload"):
		reload()
	if Input.is_action_just_pressed("Scope") and not reloading:
		spread_shoot()
	if Input.is_action_just_pressed("weapon_mode"):
		mode = not mode
		var check_button = ui.get_node("GunMode").get_node("VBoxContainer").get_node("Container").get_node("CheckButton")
		check_button.button_pressed = !check_button.button_pressed


func shoot_burst() -> void:
	if reloading:
		return
	if ammo < ammo_per_shot:
		reload()
		return
	
	is_bursting = true
	for i in range(burst_count):
		if reloading or ammo <= 0:
			break
		shoot()
		await get_tree().create_timer(burst_delay).timeout
	is_bursting = false


func spread_shoot():
	if reloading:
		return
	
	if ammo < ammo_per_shot:
		reload()
		return
	
	if not inf_ammo:
		ammo -= pellets
	
	if ammo < 0:
		ammo = 0

	for i in range(pellets):
		spawn_bb_with_spread()


func spawn_bb_with_spread() -> void:
	var dir = get_aim_direction()#spawn.global_transform.basis.z.normalized()
	
	var random_yaw = deg_to_rad(randf_range(-spread_angle, spread_angle))
	var random_pitch = deg_to_rad(randf_range(-spread_angle, spread_angle))
	var rot = Basis()
	rot = rot.rotated(Vector3.UP, random_yaw)
	rot = rot.rotated(Vector3.RIGHT, random_pitch)
	dir = (rot * dir).normalized()
	
	var mass = bb_scene.instantiate().mass if bb_scene else 0.01
	var speed = sqrt(2 * sub_energy / mass)
	spawn_bb(dir * speed, false)
