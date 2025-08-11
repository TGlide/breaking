extends CharacterBody2D
class_name Ball


func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider is Paddle:
			velocity = (Vector2.UP * 300).rotated(clampf(
				deg_to_rad((position.x - collider.position.x) / 0.5),
				deg_to_rad(-45),
				deg_to_rad(45)
			))
			Global._on_hit_paddle()

		else:
			velocity = velocity.bounce(collision.get_normal())
			Global._on_hit_wall()
	pass 
