extends Camera3D

@export var bb_node: Node3D
@export var offset: Vector3 = Vector3(0, 2, -5)


func _ready() -> void:
	pass



func _process(delta: float) -> void:
	if bb_node:
		global_transform.origin = bb_node.global_transform.origin + offset
		look_at(bb_node.global_transform.origin, Vector3.UP)
