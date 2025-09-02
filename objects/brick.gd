extends StaticBody2D
class_name Brick

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var texture: TextureRect = $TextureRect
@onready var chunk_particles: GPUParticles2D = $ChunkParticles
@onready var smoke_particles: CPUParticles2D = $SmokeParticles

var collision_dir = null

func _process(delta: float) -> void:
	if collision_dir == null: return
	texture.position += collision_dir * delta *30
	texture.modulate.a -= 5 * delta

signal hit
func on_hit(dir: Vector2) -> void:
	hit.emit()
	collision_dir = dir

	texture.modulate = Color.WHITE
	collision_shape.disabled = true
	smoke_particles.emitting = true
	chunk_particles.process_material.direction = Vector3(dir.x, dir.y, 0)
	chunk_particles.emitting = true
	chunk_particles.connect("finished",func(): queue_free())
