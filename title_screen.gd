extends Control

signal start_game

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_start_button_pressed() -> void:
	start_game.emit()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
			_on_start_button_pressed()
		elif event.keycode == KEY_ESCAPE:
			_on_quit_button_pressed()