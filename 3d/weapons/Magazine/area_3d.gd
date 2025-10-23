extends Area3D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body is CharacterBody3D:
		print("Player encostou no bloco!")

func _on_body_exited(body):
	if body is CharacterBody3D:
		print("Player saiu do bloco")
