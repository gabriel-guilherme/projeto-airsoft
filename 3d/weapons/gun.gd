extends Node3D
class_name Gun

@onready var spawn: Marker3D = $Muzzle
@onready var back_spawn: Marker3D = $BackMuzzle
@export var backspin := 0.0
@export var energy := 1.49
@export var ammo_per_shot := 1
@export var max_ammo := 10
@export var reload_time := 2.0
@export var gun_modes := []

var cam
var ammo := 10
var reloading := false
var bb_scene: PackedScene = preload("res://3d/BB/bb.tscn")
var ui

func _ready() -> void:
	cam = get_parent()
	randomize()
	ammo = max_ammo
	update_ammo_ui()
	ui = $"../../../UI"

func update_ammo_ui() -> void:
	
	if ui and ui.has_node("Ammo_Label"):
		var ammo_label = ui.get_node("Ammo_Label")
		ammo_label.text = "%d / %d" % [ammo, max_ammo]

func shoot() -> void:
	if reloading:
		return
	if ammo < ammo_per_shot:
		reload()
		return

	
	var dir = get_aim_direction()
	
	spawn_bb(dir)

func get_aim_direction() -> Vector3:
	var space = get_world_3d().direct_space_state
	var from = cam.global_position
	var to = from + cam.global_transform.basis.z * -80

	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 2
	query.exclude = [self]
	
	var result = space.intersect_ray(query)

	var target_pos: Vector3
	if result:
		target_pos = result.position
		#print("aim bot", result)
	else:
		target_pos = to
		target_pos.y += 1
		#print("sem aim bot")
	

	var dir = (target_pos - spawn.global_position).normalized()
	return dir


func get_spawn_position(dir: Vector3 = Vector3.FORWARD) -> Vector3:
	var space = get_world_3d().direct_space_state
	var spawn_pos = spawn.global_position
	var back_spawn_pos = back_spawn.global_position
	
	var check_to = spawn_pos + dir * 0.1
	var check_query = PhysicsRayQueryParameters3D.create(spawn_pos, check_to)
	var check_result = space.intersect_ray(check_query)
	
	if check_result:
		#print("Spawn bloqueado, usando back_spawn")
		return back_spawn_pos
	else:
		return spawn_pos
		
func spawn_bb(dir: Vector3 = Vector3.FORWARD, consume_ammo: bool = true) -> void:
	if ammo <= 0 and consume_ammo:
		return

	if consume_ammo:
		ammo -= ammo_per_shot

	var bb_instance = bb_scene.instantiate()
	get_tree().current_scene.add_child(bb_instance)
	#print("UE")


	bb_instance.global_position = get_spawn_position()
	bb_instance.global_rotation = spawn.global_rotation
	bb_instance.backspin = backspin

	if bb_instance is RigidBody3D:
		var mass = bb_instance.mass
		var speed = sqrt(2 * energy / mass)
		bb_instance.linear_velocity = dir * speed
		#print(dir*speed)
		#print("vel:", speed)
	
	update_ammo_ui()

func reload():
	if reloading:
		return
	reloading = true

	await get_tree().create_timer(reload_time).timeout
	ammo = max_ammo
	reloading = false
	update_ammo_ui()
