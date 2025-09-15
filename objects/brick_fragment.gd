extends RigidBody2D
class_name BrickFragment

@onready var sprite: Sprite2D = $Sprite2D
@onready var shadow: Sprite2D = $Shadow
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var lifetime: float = 6.0
var fade_time: float = 1.0
var initial_color: Color = Color.WHITE
var death_y: float = 594.0

var SCALE_UNIT = 3
var SCALE = Vector2(SCALE_UNIT, SCALE_UNIT)

func _ready():
	# Start lifetime timer
	var timer = Timer.new()
	timer.wait_time = lifetime - fade_time
	timer.one_shot = true
	timer.timeout.connect(_start_fade)
	add_child(timer)
	timer.start()

func setup(texture: Texture2D, color: Color, fragment_index: int, initial_pos: Vector2, initial_velocity: Vector2, angular_vel: float):
	position = initial_pos
	linear_velocity = initial_velocity
	angular_velocity = angular_vel
	initial_color = color
	
	sprite.texture = texture
	sprite.modulate = color
	
	# Set up sprite region for specific fragment piece (8 pieces, 5x6 each)
	sprite.region_enabled = true
	sprite.region_rect = Rect2(fragment_index * 5, 0, 5, 6)
	
	# Scale up the sprite a bit for visibility
	sprite.scale = SCALE
	
	# Set up shadow with same texture but darker
	shadow.texture = texture
	shadow.modulate = Color(0, 0, 0, 0.8)  # Black with 40% opacity
	shadow.region_enabled = true
	shadow.region_rect = Rect2(fragment_index * 5, 0, 5, 6)
	shadow.scale = SCALE
	shadow.position = Vector2(2, 2)  # Offset for shadow effect
	
	# Set up collision shape to match sprite
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(10, 12)  # 5x6 * 2 scale
	collision_shape.shape = rect_shape
	
	# Random initial rotation
	rotation = randf() * PI * 2

func _physics_process(_delta: float):
	# Check if fragment fell below death area
	if position.y > death_y:
		queue_free()

func _start_fade():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "modulate:a", 0.0, fade_time)
	tween.tween_property(shadow, "modulate:a", 0.0, fade_time)
	tween.chain().tween_callback(queue_free)
