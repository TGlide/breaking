extends RigidBody2D
class_name BrickFragment

@onready var sprite: Sprite2D = $Sprite2D
@onready var shadow: Sprite2D = $Shadow
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var lifetime: float = 6.0
var fade_time: float = 1.0
var initial_color: Color = Color.WHITE

var SCALE_UNIT = 2
var SCALE = Vector2(SCALE_UNIT, SCALE_UNIT)
var shadow_offset = Vector2(2, 2)  # Fixed shadow offset (bottom-right)

func _ready():
	# Start lifetime timer
	var timer = Timer.new()
	timer.wait_time = lifetime - fade_time
	timer.one_shot = true
	timer.timeout.connect(_start_fade)
	add_child(timer)
	timer.start()

func setup(brick: Brick, collision_direction: Vector2) -> void:
	var fragment_index = randi() % 8
	var brick_size = brick.texture.size

	position = brick.global_position + Vector2(
		randf_range(-brick_size.x * 0.3, brick_size.x * 0.3),
		randf_range(-brick_size.y * 0.3, brick_size.y * 0.3)
	)

	# Calculate velocity based on collision direction
	var base_speed = randf_range(150, 350)
	var spread_angle = randf_range(-70, 70)
	var velocity_angle = collision_direction.angle() + deg_to_rad(spread_angle)
	
	linear_velocity = Vector2(
		cos(velocity_angle) * base_speed,
		sin(velocity_angle) * base_speed - randf_range(50, 150)
	)
	
	angular_velocity = randf_range(-10, 10)

	sprite.modulate = brick.brick_color
	
	# Set up sprite region for specific fragment piece (8 pieces, 5x6 each)
	sprite.region_enabled = true
	sprite.region_rect = Rect2(fragment_index * 5, 0, 5, 6)
	
	# Scale up the sprite a bit for visibility
	sprite.scale = SCALE
	
	# Set up shadow with same texture but darker
	shadow.modulate = Color(0, 0, 0, 0.5)  
	shadow.region_enabled = true
	shadow.region_rect = Rect2(fragment_index * 5, 0, 5, 6)
	shadow.scale = SCALE
	
	# Set up collision shape to match sprite
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(10, 12)  # 5x6 * 2 scale
	collision_shape.shape = rect_shape
	
	# Random initial rotation
	rotation = randf() * PI * 2

func _physics_process(_delta: float):
	# Keep shadow at fixed offset (bottom-right) regardless of rotation
	# Shadow should stay in world space, not rotate with the fragment
	shadow.global_position = global_position + shadow_offset

func _start_fade():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "modulate:a", 0.0, fade_time)
	tween.tween_property(shadow, "modulate:a", 0.0, fade_time)
	tween.chain().tween_callback(queue_free)
