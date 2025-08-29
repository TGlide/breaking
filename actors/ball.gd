extends CharacterBody2D
class_name Ball

@onready var particle_trail: CPUParticles2D = $ParticleTrail

const BASE_VEL = -250

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider is Paddle:
			velocity = (Vector2.UP * velocity.length()).rotated(clampf(
				deg_to_rad((position.x - collider.position.x) / 0.5),
				deg_to_rad(-45),
				deg_to_rad(45)
			))
			Global._on_hit_paddle()
		elif collider is Brick:
			velocity = velocity.bounce(collision.get_normal())
			velocity = velocity.normalized() * (velocity.length() + 5)
			collider.hit()
			Global._on_hit_brick()
		else:
			velocity = velocity.bounce(collision.get_normal())
			Global._on_hit_wall()


var pos_array: Array[Vector2] = []
func _process(_delta: float) -> void:
	pos_array.append(position)
	if pos_array.size() > 10:
		pos_array.pop_front()
	
	particle_trail.emitting = velocity.length() > 0
	print(velocity.length())

func start() -> void:
		velocity.y = BASE_VEL
		# change velocity angle randomly
		velocity = velocity.rotated(deg_to_rad(randf_range(-20, 20)))

func stop() -> void:
	velocity.x = 0
	velocity.y = 0
