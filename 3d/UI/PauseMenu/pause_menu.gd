extends CanvasLayer

@onready var pause_menu = self

func _ready():
	pause_menu.visible = false


func _on_resume_pressed() -> void:
	get_parent().resume_game()


func _on_quit_pressed() -> void:
	get_tree().quit()
