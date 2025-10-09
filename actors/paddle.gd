extends CharacterBody2D
class_name Paddle

var life_texture = preload("res://assets/heart.aseprite")
var shape = preload("res://assets/paddle_shape.tres")
const LIFE_GAP = 4
const LIFE_SCALE = 0.25

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var texture_rect: TextureRect = $TextureRect
@onready var paddle_half_width: float = collision_shape.shape.size.x / 2

@export var texture: Texture

var left_boundary: float
var right_boundary: float

func update_boundaries() -> void:
	paddle_half_width = collision_shape.shape.size.x / 2
	var boundaries = Global.calculate_boundaries()
	left_boundary = boundaries.left + paddle_half_width
	right_boundary = boundaries.right - paddle_half_width

func _ready() -> void:
	reset_growy_boi()
	update_boundaries()	
	Global.move_mouse.connect(_set_position)
	Global.lives_changed.connect(display_lives)

	display_lives(Global.lives)

func display_lives(lives: int) -> void:
	get_tree().call_group("lives", "queue_free")
	if lives <= 0: return
	var texture_width = life_texture.get_width() * LIFE_SCALE
	var total_width = texture_width * (Global.lives) + LIFE_GAP * (Global.lives - 1)
	for i in range(lives):
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

# make everything wider, from the texture to the collision shape
const grow_factor = 1.5
var curr_scale: float = 1.0
var max_scale: float = 3
func growy_boi() -> void:
	if curr_scale >= max_scale: return
	curr_scale *= grow_factor
	texture_rect.size.x *= 1.5
	texture_rect.position.x = -texture_rect.size.x / 2
	collision_shape.shape.size.x *= 1.5
	update_boundaries()

func reset_growy_boi() -> void:
	texture_rect.size.x /= curr_scale
	texture_rect.position.x = -texture_rect.size.x / 2
	collision_shape.shape = shape.duplicate_deep()
	curr_scale = 1.0
	update_boundaries()
