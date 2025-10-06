extends Node2D
class_name Explosion

@onready var particles_back = $ParticlesBack
@onready var particles_front = $ParticlesFront

func explode():
	particles_back.emitting = true
	particles_front.emitting = true
	var timer = get_tree().create_timer(5.0)
	timer.connect("timeout", self.queue_free)
