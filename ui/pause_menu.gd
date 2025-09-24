extends Node
class_name PauseMenu

func _process(_delta: float) -> void:
	print("processing")
	set_process_input(true)

func _input(event: InputEvent) -> void:
	print(event.is_action_pressed("Pause"))
	if event.is_action_pressed("Pause"):
		get_tree().paused = false
		queue_free()
