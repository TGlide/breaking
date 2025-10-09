extends CharacterBody2D
class_name Ball

var ball_texture = preload("res://assets/ball.aseprite")
var piercing_texture = preload("res://assets/ball-piercing.aseprite")

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var texture_rect: TextureRect = $TextureRect
@onready var particle_trail: CPUParticles2D = $ParticleTrail
@onready var radius: float = collision_shape.shape.radius 
@onready var debug_angle: Label = $DebugAngle
@onready var fall_timer: Timer = $FallTimer
@onready var pierce_timer: Timer = $PierceTimer

const BASE_VEL = -300
const SLOW_FACTOR = 0.5

var started = false
var paddle_was_last_hit = false
var piercing = false
var slowdown = false

func _ready() -> void:
	Global.slowdown.connect(_on_slowdown)

func _physics_process(delta: float) -> void:
	if Global.freeze_ball: return

	if piercing:
		rotation = velocity.angle() + deg_to_rad(90)
	else:
		rotation = deg_to_rad(0)
	var mult = 0.5 if Global.is_slowed_down else 1.0;
	var collision = move_and_collide(velocity * delta * mult)
	var curr_angle := velocity.angle()

	if fall_timer.is_stopped():
		velocity = Vector2.from_angle(lerp_angle(curr_angle, deg_to_rad(90), 0.3 * delta)) * velocity.length()

	if collision:
		var collider = collision.get_collider()
		fall_timer.start()
		if collider is Paddle:
			var normal = collision.get_normal()

			# Hit the bottom
			if normal.y > 0.75:
				velocity = (Vector2.DOWN * velocity.length())
			elif normal.y > 0:
				velocity = velocity.bounce(normal)
			else:
				var dist_from_center = global_position.x - collider.global_position.x
				var half_width = collider.get_node("CollisionShape2D").shape.size.x / 2
				var percent_from_center = dist_from_center / half_width

				velocity = (Vector2.UP * velocity.length()).rotated(deg_to_rad(percent_from_center * 45))

			var counter = 0
			while collision and counter < 30:
				collision = move_and_collide(velocity * delta)
				counter += 1
			
			Global._on_hit_paddle()
		elif collider is Brick:
			collider.on_hit(velocity.normalized())
			if not piercing:
				velocity = velocity.bounce(collision.get_normal())
			velocity = velocity.normalized() * (velocity.length() + 5)
		else:
			velocity = velocity.bounce(collision.get_normal())
			Global._on_hit_wall()


func _process(_delta: float) -> void:
	debug_angle.text = str(round(rad_to_deg(velocity.angle())))

func start(pos: Vector2 = Vector2.ZERO) -> void:
	particle_trail.emitting = true
	position = pos
	velocity.y = BASE_VEL
	# change velocity angle randomly
	velocity = velocity.rotated(deg_to_rad(randf_range(-20, 20)))
	fall_timer.start()


func stop() -> void:
	velocity.x = 0
	velocity.y = 0


func _on_slowdown(value: bool) -> void:
	if value and not slowdown:
		fall_timer.wait_time /= SLOW_FACTOR
		pierce_timer.wait_time /= SLOW_FACTOR
	elif not value and slowdown:
		fall_timer.wait_time *= SLOW_FACTOR
		pierce_timer.wait_time *= SLOW_FACTOR
	slowdown = value

func enable_piercing() -> void:
	piercing = true
	texture_rect.texture = piercing_texture
	pierce_timer.start()


func _on_pierce_timer_timeout() -> void:
	piercing = false
	texture_rect.texture = ball_texture
