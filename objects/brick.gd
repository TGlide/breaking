extends StaticBody2D
class_name Brick

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var texture: TextureRect = $TextureRect
@onready var chunk_particles: GPUParticles2D = $ChunkParticles
@onready var smoke_particles: CPUParticles2D = $SmokeParticles

func hit() -> void:
	# change texture to white briefly
	texture.modulate = Color.WHITE
	# offset the texture slightly
	texture.position.x += randf_range(-0.1, 0.1)
	texture.position.y += randf_range(-0.1, 0.1)
	# hide the texture for a bit
	var timer = get_tree().create_timer(0.2)
	timer.connect("timeout", func(): texture.hide())

	collision_shape.disabled = true
	smoke_particles.emitting = true
	chunk_particles.emitting = true
	chunk_particles.connect("finished", func(): queue_free())
