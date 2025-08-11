extends Node
class_name Level

@onready var paddle: Paddle = $Paddle
@onready var ball: Ball = $Ball

var started = false

func _input(event: InputEvent) -> void:
	var mouse_click = event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT
	if mouse_click:
		started = true
		ball.velocity.y = -300
		# change velocity angle randomly
		ball.velocity = ball.velocity.rotated(deg_to_rad(randf_range(-20, 20)))

func _process(delta: float) -> void:
	if not started:
		ball.position.x = paddle.position.x
		ball.position.y = paddle.position.y - 16


