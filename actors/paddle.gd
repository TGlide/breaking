extends CharacterBody2D
class_name Paddle

var life_texture = preload("res://assets/heart.aseprite")
const LIFE_GAP = 4
const LIFE_SCALE = 0.5

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var paddle_half_width: float = collision_shape.shape.size.x / 2

@export var texture: Texture

var left_boundary: float
var right_boundary: float

func _ready() -> void:
	var boundaries = Global.calculate_boundaries()
	left_boundary = boundaries.left + paddle_half_width
	right_boundary = boundaries.right - paddle_half_width
	Global.move_mouse.connect(_set_position)
	Global.die.connect(display_lives)

	display_lives()

func display_lives() -> void:
	get_tree().call_group("lives", "queue_free")
	if Global.lives <= 0: return
	var texture_width = life_texture.get_width() * LIFE_SCALE
	var total_width = texture_width * (Global.lives) + LIFE_GAP * (Global.lives - 1)
	for i in range(Global.lives):
		var life = TextureRect.new()
		life.stretch_mode = TextureRect.STRETCH_SCALE
		life.add_to_group("lives")
		life.texture = life_texture
		life.size.x = life_texture.get_width()
		life.size.y = life_texture.get_height()
		life.scale = Vector2(LIFE_SCALE, LIFE_SCALE)
		life.position.x = -total_width / 2 + (texture_width + LIFE_GAP) * i 
		life.position.y = life.size.y / 2
		add_child(life)


# x is determined in percent of the viewport.
func _set_position(x: float) -> void:	
	var total_width = right_boundary - left_boundary
	position.x = x * total_width + left_boundary
