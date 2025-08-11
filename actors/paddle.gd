extends CharacterBody2D
class_name Paddle

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var paddle_half_width: float = collision_shape.shape.size.x / 2

var left_boundary: float
var right_boundary: float


func _ready() -> void:
	_calculate_boundaries()

func _calculate_boundaries() -> void:
	var walls = get_tree().get_nodes_in_group("walls")
	
	if walls.size() >= 2:
		var wall_positions = []
		for wall in walls:
			var wall_collision = wall.get_node("CollisionShape2D")
			var wall_shape = wall_collision.shape as RectangleShape2D
			var wall_half_width = wall_shape.size.x / 2
			wall_positions.append({
				"left": wall.global_position.x - wall_half_width,
				"right": wall.global_position.x + wall_half_width
			})
		
		# Sort by position and get boundaries
		wall_positions.sort_custom(func(a, b): return a.left < b.left)
		left_boundary = wall_positions[0].right + paddle_half_width
		right_boundary = wall_positions[-1].left - paddle_half_width

func _input(event: InputEvent) -> void:	
	if event is InputEventMouseMotion:
		position.x = clamp(event.position.x, left_boundary, right_boundary)
