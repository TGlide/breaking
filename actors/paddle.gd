extends CharacterBody2D
class_name Paddle

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var paddle_half_width: float = collision_shape.shape.size.x / 2

@export var texture: Texture

var left_boundary: float
var right_boundary: float


func _ready() -> void:
	var boundaries = Global.calculate_boundaries()
	left_boundary = boundaries.left + paddle_half_width
	right_boundary = boundaries.right - paddle_half_width


func _input(event: InputEvent) -> void:	
	if event is InputEventMouseMotion:
		position.x = clamp(event.position.x, left_boundary, right_boundary)
