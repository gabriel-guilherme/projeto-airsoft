extends Node3D

@export var target_scene: PackedScene
@export var spawner: Node3D
@export var time_per_round := 4
@export var player: Node3D
@export var start_button: StaticBody3D
@export var interact_label: Label
@export var round_canvas_layer : CanvasLayer

var camera: Camera3D
var round2 := 1
var targets_left := 0
var time_left := 4
var used_spawns: Array = []
var looking_at_button := false


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if player and player.has_node("CameraPivot/Camera3D"):
		camera = player.get_node("CameraPivot/Camera3D")
	else:
		push_error("Câmera não encontrada! Verifique se o caminho é Player/CameraPivot/Camera3D.")

func _process(_delta):
	var result = get_look_ray_result()
	if result and result.collider == start_button:
		if not looking_at_button:
			looking_at_button = true
			interact_label.visible = true
	else:
		if looking_at_button:
			looking_at_button = false
			interact_label.visible = false

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if event.is_action_pressed("interact"):
		check_button_interaction()

func get_look_ray_result() -> Dictionary:
	if not camera or not is_instance_valid(camera):
		return {}
	var from = camera.global_position
	var to = from + camera.global_transform.basis.z * -5.0
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	return space.intersect_ray(query)

func check_button_interaction():
	var result = get_look_ray_result()
	if result and result.collider == start_button:
		print("Botão Start atingido — iniciando rodada!")
		round2 = 1
		targets_left = 0
		time_left = 4
		start_round(round2)
		$Timer.wait_time = 1.0
		round_canvas_layer.visible = true
		$Timer.start()
	else:
		print("Nada atingido ou não é o botão.")

func start_round(num):
	used_spawns.clear()
	clear_targets()

	var num_targets = 2 + num * 2
	time_left = time_per_round + (round2 - 1) * 1.5
	targets_left = num_targets

	spawn_targets(num_targets)
	update_ui()
	print("Iniciando rodada %d com %d alvos e %.1fs" % [round2, targets_left, time_left])

func spawn_targets(amount):
	if spawner == null or not is_instance_valid(spawner):
		push_error("Spawner inválido!")
		return

	var spawn_groups = spawner.get_children()
	if spawn_groups.is_empty():
		push_error("Nenhum grupo de spawn encontrado!")
		return

	for i in range(amount):
		var group = spawn_groups.pick_random()
		if not is_instance_valid(group):
			continue

		var group_points = group.get_children()
		if group_points.is_empty():
			continue

		var spawn = group_points.pick_random()
		var tries := 0
		while spawn in used_spawns and tries < 20:
			spawn = group_points.pick_random()
			tries += 1

		if spawn in used_spawns:
			continue

		used_spawns.append(spawn)
		var target = target_scene.instantiate()
		add_child(target)
		target.global_position = spawn.global_position
		target.connect("target_destroyed", Callable(self, "_on_target_destroyed"))

func clear_targets():
	for target in get_tree().get_nodes_in_group("targets"):
		target.queue_free()

func _on_target_destroyed():
	targets_left -= 1
	update_ui()
	if targets_left <= 0:
		round2 += 1
		start_round(round2)

func _on_timer_timeout():
	time_left -= 1
	update_ui()
	if time_left <= 0:
		game_over()

func update_ui():
	
	round_canvas_layer.get_node("LabelRound").text = "Rodada: %d" % round2
	round_canvas_layer.get_node("LabelTargets").text = "Alvos: %d" % targets_left
	round_canvas_layer.get_node("LabelTime").text = "%.1f" % time_left

func game_over():
	clear_targets()
	$Timer.stop()
	round_canvas_layer.visible = false
