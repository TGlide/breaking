extends CharacterBody2D
class_name Ball

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var particle_trail: CPUParticles2D = $ParticleTrail
@onready var radius: float = collision_shape.shape.radius 

const BASE_VEL = 200

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider is Paddle:
			var normal = collision.get_normal()
			
			if normal.y < -0.5:  # Hit the top surface
				velocity = (Vector2.UP * velocity.length()).rotated(clampf(
					deg_to_rad((position.x - collider.position.x) / 0.5),
					deg_to_rad(-45),
					deg_to_rad(45)
				))
			else:  # Hit the sides
				var cur_vel = velocity.length()
				var col_v = collision.get_collider_velocity()
				print(col_v.length())
				if col_v.length() < 200:
					col_v = col_v.normalized() * 200
				if col_v.length() > 500:
					print("too much velocity")
					col_v = col_v.normalized() * 500
				
				print(collision.get_collider_velocity())
				velocity = velocity.bounce(normal)
				velocity += col_v
				var counter = 0
				while collision and counter < 100:
					collision = move_and_collide(col_v * delta)
					counter += 1

				print("collided ", counter, " times")
				print()

				print(collider)
			
			Global._on_hit_paddle()
		elif collider is Brick:
			velocity = velocity.bounce(collision.get_normal())
			velocity = velocity.normalized() * (velocity.length() + 5)
			collider.hit()
			Global._on_hit_brick()
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
