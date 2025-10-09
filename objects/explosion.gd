extends Area2D
class_name Explosion

@onready var particles_back: CPUParticles2D = $ParticlesBack
@onready var particles_front: CPUParticles2D = $ParticlesFront
@onready var stream_player: AudioStreamPlayer = $AudioStreamPlayer

func explode():
	particles_back.emitting = true
	particles_front.emitting = true
	stream_player.play()
	var timer = get_tree().create_timer(5.0)
	timer.connect("timeout", self.queue_free)
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body is Brick:
			var dir = body.global_position - global_position
			body.on_hit(dir * 0.1)
