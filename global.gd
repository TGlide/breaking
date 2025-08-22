extends Node

@onready var hit_sound: AudioStreamPlayer = $HitSoundPlayer
@onready var break_sound: AudioStreamPlayer = $BreakSoundPlayer
@onready var hit_brick_sound: AudioStreamPlayer = $HitBrickSoundPlayer


var hit_brick_sound_counter = 0

func _on_hit_wall() -> void:
	hit_sound.pitch_scale = 1.0 
	hit_sound.play()

func _on_hit_paddle() -> void:
	hit_brick_sound_counter = 0
	hit_sound.pitch_scale = 1.1
	hit_sound.play()

const MAX_BRICK_HIT_SOUND = 8
func _on_hit_brick() -> void:
	hit_brick_sound_counter = clampi(hit_brick_sound_counter + 1, 0, MAX_BRICK_HIT_SOUND)
	hit_brick_sound.pitch_scale = 0.9 + (hit_brick_sound_counter * 0.1)
	hit_brick_sound.play()
	break_sound.play()
