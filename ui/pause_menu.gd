extends CanvasLayer
class_name PauseMenu

func _input(_event: InputEvent) -> void:
	if Input.is_action_pressed("Pause"):
		if not visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			show()
			get_tree().paused = true
		else:
			_on_resume_button_pressed()

func _on_resume_button_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().paused = false
	hide()


func _on_give_up_button_pressed() -> void:
	Global.game_over()
	get_tree().paused = false
