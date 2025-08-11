extends StaticBody2D
class_name Brick

@onready var texture: TextureRect = $TextureRect
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var smoke_particles: CPUParticles2D = $SmokeParticles
@onready var chunk_particles: GPUParticles2D = $ChunkParticles

func hit() -> void:
	texture.hide()
	collision_shape.disabled = true
	smoke_particles.emitting = true
	chunk_particles.emitting = true
	chunk_particles.connect("finished", func(): queue_free())
