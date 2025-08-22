extends Node
class_name Level

@onready var paddle: Paddle = $Paddle
@onready var ball: Ball = $Ball

var started = false

func _input(event: InputEvent) -> void:
	var mouse_click = event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT
	if mouse_click:
		started = true
		ball.start()

func _process(_delta: float) -> void:
	if not started:
		ball.position.x = paddle.position.x
		ball.position.y = paddle.position.y - 16
		return

	# rotate paddle according to ball x distance to paddle's center
	paddle.rotation = clampf(
		deg_to_rad((ball.position.x - paddle.position.x) / 10),
		deg_to_rad(-2.5),
		deg_to_rad(2.5)
	)
