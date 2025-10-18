extends Gun

@export var fire_rate := 6.0
var _time_since_last_shot := 0.0
var auto = true


func _process(delta: float) -> void:
	_time_since_last_shot += delta

	if auto:
		if Input.is_action_pressed("Fire"):
			shoot()
	else:
		if Input.is_action_just_pressed("Fire"):
			shoot()

	if Input.is_action_just_pressed("Reload"):
		reload()
	
	if Input.is_action_just_pressed("weapon_mode"):
		auto = not auto


func shoot():
	if reloading:
		return

	if ammo < ammo_per_shot:
		#print("Sem munição!")
		reload()
		return

	if auto:
		var delay = 1.0 / fire_rate
		if _time_since_last_shot < delay:
			return

		_time_since_last_shot = 0.0
		

	var dir = get_aim_direction()
	#print(dir)
	spawn_bb(dir)
