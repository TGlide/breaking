extends CanvasLayer
class_name PauseMenu

func _on_resume_button_pressed() -> void:
	print("resume")
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().paused = false
	hide()
