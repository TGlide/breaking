extends Node2D

@onready var hit_sound: AudioStreamPlayer = $HitSoundPlayer
@onready var break_sound: AudioStreamPlayer = $BreakSoundPlayer
@onready var hit_brick_sound: AudioStreamPlayer = $HitBrickSoundPlayer
@onready var voice_player: AudioStreamPlayer = $VoicePlayer
@onready var bgm_player: AudioStreamPlayer = $BgmPlayer

var combo_vls = [ 
	preload("res://assets/voice/amazing.wav"),
	preload("res://assets/voice/incredible.wav"),
	preload("res://assets/voice/combo.wav"),
	preload("res://assets/voice/good-job.wav"),
	preload("res://assets/voice/nice.wav"),
	preload("res://assets/voice/you-rock.wav"),
	preload("res://assets/voice/unstoppable.wav"),
]

var death_vls = [
	preload("res://assets/voice/aww.wav"),
	preload("res://assets/voice/not-this-time.wav"),
	preload("res://assets/voice/no-noo.wav"),
	preload("res://assets/voice/you-lose.wav"),
	preload("res://assets/voice/what-a-loser.wav"),
	preload("res://assets/voice/oops.wav"),
]

const MAX_MULT = 9
const MAX_WIDTH = 1800.0
const POWERUPS = ["extra-ball", "bigger-paddle"]

const LEVEL_SCENE = preload("res://screens/level.tscn")
const TITLE_SCREEN = preload("res://screens/title_screen.tscn")
const GAME_OVER_SCREEN = preload("res://screens/game_over.tscn")

signal move_mouse(x: float)
signal mouse_click
signal update_score(score: int)
signal update_mult(mult: int)
signal die
signal change_screen(scene: PackedScene)
signal hit_brick

var lives = 3
var score = 0
var mult = 1
var level = 1
var freeze_ball = false

var consecutive_hits = 0
var next_voice_trigger = randi_range(4, 6)
var paddle_was_last_hit = false

var music_path = "res://assets/music/"
func get_random_music() -> String:
	var music_files: Array[String] = []
	var dir := DirAccess.open(music_path)
	dir.list_dir_begin()
	for file: String in dir.get_files():
		if !file.ends_with(".wav"): continue
		music_files.append(file)
	
	return music_files[randi() % music_files.size()]

func play_random_music() -> void:
	bgm_player.stream = load(music_path + get_random_music())
	bgm_player.play()

func _ready() -> void:
	play_random_music()
	bgm_player.finished.connect(play_random_music)


var last_combo_i = -1
func _get_rand_combo_vl():
	var i = randi() % combo_vls.size()
	if i == last_combo_i:
		return _get_rand_combo_vl()
	last_combo_i = i
	return combo_vls[i]


func reset_mult() -> void:
	mult = 1
	consecutive_hits = 0
	next_voice_trigger = randi_range(4, 6)
	update_mult.emit(mult)

var levels_path = "res://levels/"
func next_level() -> void:
	Global.reset_mult()
	Global.freeze_ball = false
	var total_levels = 0

	var dir := DirAccess.open(levels_path)
	dir.list_dir_begin()
	for file: String in dir.get_files():
		if !file.ends_with(".json"): continue
		total_levels += 1

	if total_levels == 0: return
	level += 1
	if level > total_levels: level = 1
	change_screen.emit(LEVEL_SCENE)

func _on_hit_wall() -> void:
	paddle_was_last_hit = false
	hit_sound.pitch_scale = 1.0 
	hit_sound.play()

func _on_hit_paddle() -> void:
	reset_mult()
	if !paddle_was_last_hit:
		hit_sound.pitch_scale = 1.1
		hit_sound.play()
	paddle_was_last_hit = true

func _on_hit_brick() -> void:
	paddle_was_last_hit = false
	score += 10 * mult
	consecutive_hits += 1
	mult = mini(mult + 1, MAX_MULT)

	update_score.emit(score)
	update_mult.emit(mult)
	hit_brick.emit()

	if consecutive_hits == next_voice_trigger and !voice_player.playing:
		var combo_vl = _get_rand_combo_vl()
		voice_player.stream = combo_vl
		var timer = get_tree().create_timer(0.1)
		timer.connect("timeout", func(): voice_player.play())
		next_voice_trigger += randi_range(5, 9)
		 

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


func _input(event: InputEvent) -> void:	
	var mouse_clicked = event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT
	if mouse_clicked:
		mouse_click.emit()

	if event is not InputEventMouseMotion: return

	var viewport_size = get_viewport_rect().size
	var margin = maxi(viewport_size.x - MAX_WIDTH, 0) / 2.0
	var mouse_area = viewport_size.x - margin * 2
	var x = clamp(event.position.x - margin, 0, mouse_area)
	var x_percent = x / mouse_area
	move_mouse.emit(x_percent)

func _on_die() -> void:
	lives = max(lives - 1, 0)
	die.emit()
	reset_mult()

	var random_index = randi() % death_vls.size()
	var death_vl = death_vls[random_index]
	voice_player.stream = death_vl
	voice_player.play()

	if lives == 0:
		change_screen.emit(GAME_OVER_SCREEN)
		Global.lives = 3
		Global.level = 1
