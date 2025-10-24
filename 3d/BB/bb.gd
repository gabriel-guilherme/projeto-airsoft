extends RigidBody3D

var launched := false
var spawn_pos: Vector3
var backspin
@onready var trail_particles: GPUParticles3D = $TrailParticles

var radius := 0.003
var Cd := 0.47 
var p := 1.225 
var transversal := PI * pow(radius, 2)

var bullet_mark_scene: PackedScene = preload("res://3d/BB/bb_mark.tscn")

var prev_position: Vector3

func set_spawn_pos(pos: Vector3) -> void:
	spawn_pos = pos

func _ready() -> void:
	gravity_scale = 0.0
	linear_damp = 0
	#mass = 0.0002
	contact_monitor = true
	max_contacts_reported = 4
	prev_position = global_position

func _physics_process(_delta: float) -> void:
	
	var speed = linear_velocity.length()

	if speed > 0.001:
		var drag_force_mag = 0.5 * p * speed * speed * Cd * transversal
		var drag_direction = linear_velocity.normalized()
		var drag_force = -drag_direction * drag_force_mag
		apply_central_force(drag_force)
		
	
		if launched:
			var v_backspin_force = global_transform.basis.y * sqrt(speed) * (backspin / 100)
			apply_central_force(v_backspin_force)
			backspin *= 0.98
		else:
			fall()

	#  colisão
	if get_contact_count() > 0:
		var collider = get_colliding_bodies()[0]
		_create_bullet_mark(prev_position, collider)

		if collider and collider is RigidBody3D:
			if collider.has_method("hit"):
				collider.hit()

		queue_free()

	prev_position = global_position


func fall() -> void:
	gravity_scale = 1.0
	launched = true


func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	pass
	#queue_free()


func _create_bullet_mark(location, collider) -> void:
	
	var mark = bullet_mark_scene.instantiate()
	collider.add_child(mark)

	mark.global_position = location
