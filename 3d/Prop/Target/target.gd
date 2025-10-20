extends RigidBody3D
signal target_destroyed

func _ready():
	pass

func hit():
	emit_signal("target_destroyed")
	queue_free()
