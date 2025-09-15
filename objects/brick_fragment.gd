extends Node2D
class_name BrickFragment

@onready var sprite: Sprite2D = $Sprite2D

var velocity: Vector2 = Vector2.ZERO
var angular_velocity: float = 0.0
var gravity: float = 800.0
var bounce_dampening: float = 0.6
var friction: float = 0.98
var ground_y: float = 600.0
var lifetime: float = 3.0
var fade_time: float = 1.0

var initial_color: Color = Color.WHITE
var is_physics_enabled: bool = true
var has_hit_ground: bool = false
var wall_left: float = 0.0
var wall_right: float = 640.0
var death_y: float = 594.0

func _ready():
	var timer = Timer.new()
	timer.wait_time = lifetime - fade_time
	timer.one_shot = true
	timer.timeout.connect(_start_fade)
	add_child(timer)
	timer.start()

func setup(texture: Texture2D, color: Color, fragment_index: int, initial_pos: Vector2, initial_velocity: Vector2, angular_vel: float):
	position = initial_pos
	velocity = initial_velocity
	angular_velocity = angular_vel
	initial_color = color
	
	sprite.texture = texture
	sprite.modulate = color
	
	# Set up sprite region for specific fragment piece (8 pieces, 5x6 each)
	sprite.region_enabled = true
	sprite.region_rect = Rect2(fragment_index * 5, 0, 5, 6)
	
	# Scale up the sprite a bit for visibility
	sprite.scale = Vector2(2, 2)
	
	rotation = randf() * PI * 2

func _process(delta: float):
	if not is_physics_enabled:
		return
	
	# Check if fragment fell below death area
	if position.y > death_y:
		queue_free()
		return
		
	velocity.y += gravity * delta
	
	if has_hit_ground:
		velocity *= friction
	
	position += velocity * delta
	rotation += angular_velocity * delta
	
	# Wall collision detection
	if position.x <= wall_left:
		position.x = wall_left
		velocity.x = abs(velocity.x) * bounce_dampening
		angular_velocity *= 0.8
	elif position.x >= wall_right:
		position.x = wall_right
		velocity.x = -abs(velocity.x) * bounce_dampening
		angular_velocity *= 0.8
	
	# Ground collision
	if position.y >= ground_y and not has_hit_ground:
		position.y = ground_y
		velocity.y *= -bounce_dampening
		velocity.x *= 0.7
		angular_velocity *= 0.6
		has_hit_ground = true
		
		if abs(velocity.y) < 30:
			velocity.y = 0
			is_physics_enabled = false

func _start_fade():
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, fade_time)
	tween.tween_callback(queue_free)
