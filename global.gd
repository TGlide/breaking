extends Node2D

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


func calculate_boundaries() -> Dictionary[String, float]:
	var walls: Array[Node] = get_tree().get_nodes_in_group("walls") as Array[Node]
	
	if walls.size() >= 2:
		var wall_positions = []
		for w in walls:
			var wall = w as StaticBody2D
			# ignore ceilings
			if (wall.rotation != 0): continue
			var wall_collision = wall.get_node("CollisionShape2D")
			var wall_shape = wall_collision.shape as RectangleShape2D
			var wall_half_width = wall_shape.size.x * wall.scale.x / 2
			wall_positions.append({
				"left": wall.global_position.x - wall_half_width,
				"right": wall.global_position.x + wall_half_width
			})
		
		# Sort by position and get boundaries
		wall_positions.sort_custom(func(a, b): return a.left < b.left)

		return {
			'left': wall_positions[0].right,
			'right': wall_positions[-1].left 
		}
		
	return {
		'left': 0.0,
		'right': 0.0
	}


const MAX_WIDTH = 1800.0
signal move_mouse(x: float)
func _input(event: InputEvent) -> void:	
	if event is not InputEventMouseMotion: return

	var viewport_size = get_viewport_rect().size
	var margin = maxi(viewport_size.x - MAX_WIDTH, 0) / 2
	var mouse_area = viewport_size.x - margin * 2
	print("Mouse Area: ", mouse_area)
	print("Margin: ", margin)
	print("Viewport Size: ", viewport_size)
	print("Event Position: ", event.position)
	var x = clamp(event.position.x - margin, 0, mouse_area)
	print("X: ", x)
	var x_percent = x / mouse_area
	print("X Percent: ", x_percent)
	move_mouse.emit(x_percent)
	# move_mouse.emit(event.position.x / viewport_size.x)
