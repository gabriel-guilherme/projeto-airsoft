extends CanvasLayer

func _ready():
	#$Label.text = "🏁 Fim do Treino!\nParabéns, soldado!"
	#$Button.text = "Recomeçar"
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$Button.connect("pressed", Callable(self, "_on_restart_pressed"))

func _on_restart_pressed():
	get_tree().change_scene_to_file("res://3d/main.tscn")
