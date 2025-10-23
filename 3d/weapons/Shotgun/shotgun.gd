extends Gun

@export var pellets := 6
@export var spread_angle := 10.0
@export var sub_energy := 0.001

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Fire") and not reloading:
		shoot()
	
	if Input.is_action_pressed("energy_up"):
		change_energy(0.005)
	
	if Input.is_action_pressed("energy_down"):
		change_energy(-0.005)
	
	if Input.is_action_just_pressed("Reload"):
		reload()

func shoot():
	if reloading:
		return
	
	if ammo < ammo_per_shot:
		#print("Sem munição!")
		reload()
		return
		
	if not inf_ammo:
		ammo -= ammo_per_shot

	for i in range(pellets):
		spawn_bb_with_spread()
	#print("Munição:", ammo, "/", max_ammo)

func spawn_bb_with_spread() -> void:
	var dir = get_aim_direction()#spawn.global_transform.basis.z.normalized()
	
	var random_yaw = deg_to_rad(randf_range(-spread_angle, spread_angle))
	var random_pitch = deg_to_rad(randf_range(-spread_angle , spread_angle))
	var rot = Basis()
	rot = rot.rotated(Vector3.UP, random_yaw)
	rot = rot.rotated(Vector3.RIGHT, random_pitch)
	dir = (rot * dir).normalized()
	
	var mass = bb_scene.instantiate().mass if bb_scene else 0.01
	var speed = sqrt(2 * sub_energy / mass)
	spawn_bb(dir * speed, false)
	#ammo -= 1
