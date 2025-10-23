extends Gun

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Fire") and not reloading:
		shoot()
	
	if Input.is_action_pressed("energy_up"):
		change_energy(0.005)
	
	if Input.is_action_pressed("energy_down"):
		change_energy(-0.005)
	
	if Input.is_action_just_pressed("Reload"):
		reload()
