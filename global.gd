extends Node2D

@onready var hit_sound: AudioStreamPlayer = $HitSoundPlayer
@onready var break_sound: AudioStreamPlayer = $BreakSoundPlayer
@onready var hit_brick_sound: AudioStreamPlayer = $HitBrickSoundPlayer

var lives = 3
var score = 0

var mult = 1
const MAX_MULT = 9

func _on_hit_wall() -> void:
	hit_sound.pitch_scale = 1.0 
	hit_sound.play()

func _on_hit_paddle() -> void:
	mult = 1
	hit_sound.pitch_scale = 1.1
	hit_sound.play()

signal update_score(score: int)
const MAX_BRICK_HIT_SOUND = 8
func _on_hit_brick() -> void:
	score += 100 * mult
	update_score.emit(score)
	mult = mini(mult + 1, MAX_MULT)
	hit_brick_sound.pitch_scale = 0.9 + ((mult - 1) * 0.1)
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
	var x = clamp(event.position.x - margin, 0, mouse_area)
	var x_percent = x / mouse_area
	move_mouse.emit(x_percent)

signal die
func _on_die() -> void:
	lives = max(lives - 1, 0)
	die.emit()
