extends RigidBody3D

@export_range(0.0, 1.0, 0.00001)
var bb_mass: float
@export var ammo: int
@export var gun: PackedScene
@export var inf_ammo: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		var weapon = body.current_weapon
		if weapon.get_scene_file_path() == gun.resource_path:
			if inf_ammo:
				weapon.ammo = weapon.max_ammo
				weapon.inf_ammo = not weapon.inf_ammo
			else:
				weapon.bb_mass = bb_mass
				weapon.ammo = ammo
			weapon.update_weapon_ui()
