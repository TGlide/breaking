extends Node

@onready var hit_sound: AudioStreamPlayer = $HitSoundPlayer
@onready var break_sound: AudioStreamPlayer = $BreakSoundPlayer

func _on_hit_wall() -> void:
	hit_sound.pitch_scale = 1.0 
	hit_sound.play()

func _on_hit_paddle() -> void:
	hit_sound.pitch_scale = 1.1
	hit_sound.play()

func _on_hit_brick() -> void:
	hit_sound.pitch_scale = 1.5
	hit_sound.play()
	break_sound.play()
