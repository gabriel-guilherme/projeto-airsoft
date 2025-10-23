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
@export var bb_mass := 0.0002
@export var inf_ammo : bool

var mode = false
var cam
var ammo := 10
var reloading := false
var bb_scene: PackedScene = preload("res://3d/BB/bb.tscn")
var ui
var reload_id := 0
var reload_timer

func _ready() -> void:
	cam = get_parent()
	randomize()
	ammo = max_ammo
	update_weapon_ui()
	ui = $"../../../UI"

func update_weapon_ui() -> void:
	if ui:
		var backspin_info = ui.get_node("Backspin_Info")
		var slider = backspin_info.get_node("HSlider")
		backspin = slider.value
		
		var gun_info = ui.get_node("Gun_Info")

		var ammo_label = gun_info.get_node("Ammo_Label")
		#print(ammo_label)
		ammo_label.text = "%d / %d" % [ammo, max_ammo]
		
		var bbmass_label = gun_info.get_node("BBMass_Label")
		bbmass_label.text = "%sg" % [String.num(bb_mass * 1000, 2)]
		#print(bb_mass)
		
		var energy_label = gun_info.get_node("Energy_Label")
		energy_label.text = "%s j" % [String.num(energy, 2)]
		
		var reloading_label = ui.get_node("Reloading_Label")
		reloading_label.visible = false

		var gun_mode = ui.get_node("GunMode")
		var vbox_container = gun_mode.get_node("VBoxContainer")
		if gun_modes.size() > 0:
			gun_mode.visible = true
			vbox_container.get_node("Mode1_Label").text = gun_modes[0]
			vbox_container.get_node("Mode2_Label").text = gun_modes[1]
			vbox_container.get_node("Container").get_node("CheckButton").button_pressed = mode
		else:
			gun_mode.visible = false

func shoot() -> void:
	if reloading:
		return
	if ammo < ammo_per_shot:
		reload()
		return

	
	var dir = get_aim_direction()
	
	spawn_bb(dir)

func change_energy(amount: float):
	energy = energy + amount
	if energy < 0:
		energy = 0
	update_weapon_ui()

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

	if consume_ammo and not inf_ammo:
		ammo -= ammo_per_shot

	var bb_instance = bb_scene.instantiate()
	get_tree().current_scene.add_child(bb_instance)
	#print("UE")


	bb_instance.global_position = get_spawn_position()
	bb_instance.global_rotation = spawn.global_rotation
	bb_instance.backspin = backspin
	bb_instance.mass = bb_mass

	if bb_instance is RigidBody3D:
		var mass = bb_instance.mass
		var speed = sqrt(2 * energy / mass)
		bb_instance.linear_velocity = dir * speed
		#print(dir*speed)
		print("vel:", speed)
	
	update_weapon_ui()

func reload():
	if reloading or ammo == max_ammo:
		return
	
	reloading = true
	reload_id += 1
	var current_id = reload_id

	var reloading_label = ui.get_node("Reloading_Label")
	reloading_label.visible = true

	reload_timer = await get_tree().create_timer(reload_time).timeout

	if visible and reload_id == current_id:
		ammo = max_ammo
		update_weapon_ui()
	
	reloading = false

func cancel_reload():
	if reload_timer:
		
		reload_timer.stop()
		reload_timer = null
