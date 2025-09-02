extends CharacterBody2D
class_name Ball

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var particle_trail: CPUParticles2D = $ParticleTrail
@onready var radius: float = collision_shape.shape.radius 

const BASE_VEL = -300

func _physics_process(delta: float) -> void:
	if Global.freeze_ball: return
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider is Paddle:
			var normal = collision.get_normal()

			# Hit the bottom
			if normal.y > 0.75:
				velocity = (Vector2.DOWN * velocity.length())
			elif normal.y > 0:
				velocity = velocity.bounce(normal)
			else:
				velocity = (Vector2.UP * velocity.length()).rotated(clampf(
					deg_to_rad((position.x - collider.position.x) / 0.5),
					deg_to_rad(-45),
					deg_to_rad(45)
				))

			var counter = 0
			while collision and counter < 30:
				collision = move_and_collide(velocity * delta)
				counter += 1
			
			Global._on_hit_paddle()
		elif collider is Brick:
			Global._on_hit_brick()
			collider.on_hit(velocity.normalized())
			velocity = velocity.bounce(collision.get_normal())
			velocity = velocity.normalized() * (velocity.length() + 5)
		else:
			velocity = velocity.bounce(collision.get_normal())
			Global._on_hit_wall()


func _process(_delta: float) -> void:
	particle_trail.emitting = velocity.length() > 0

func start() -> void:
		velocity.y = BASE_VEL
		# change velocity angle randomly
		velocity = velocity.rotated(deg_to_rad(randf_range(-20, 20)))

func stop() -> void:
	velocity.x = 0
	velocity.y = 0
