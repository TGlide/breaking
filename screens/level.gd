extends Node
class_name Level

const brick_scene: PackedScene = preload("res://objects/brick.tscn")
const ball_scene: PackedScene = preload("res://actors/ball.tscn")

@onready var paddle: Paddle = $Paddle
@onready var score_label: Label = $Score
@onready var mult_label: Label = $Multiplier
@onready var pause_menu: PauseMenu = $PauseMenu


const MARGIN_HOR = 72
const MARGIN_TOP = 116
const GAP_Y = 4

var bricks = []
var total_bricks = 0
var total_balls = 1
var started = false
var last_powerup: String

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Global.update_score.connect(_on_update_score)
	Global.update_mult.connect(_on_update_mult)
	Global.mouse_click.connect(_on_mouse_click)
	_on_update_score(Global.score)
	_on_update_mult(Global.mult)

	load_level()
	create_bricks()

func load_level() -> void:
	var file = FileAccess.open("res://levels/%s.json" % Global.level, FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_text)
		
		if parse_result == OK:
			var level_data = json.data
			var brick_data = level_data["bricks"]
			
			for row in brick_data:
				var row_configs = []
				for brick in row:
					total_bricks += 1
					var color_name = brick["color"]
					var color = Constants.COLORS.get(color_name, Color.WHITE)
					row_configs.append({"color": color, "power": brick.has("power")})
				bricks.append(row_configs)

func create_bricks() -> void:
	var boundaries = Global.calculate_boundaries()
	var available_width = boundaries.right - boundaries.left

	var total_cols = 0
	for row in bricks:
		total_cols = max(total_cols, row.size())

	for row in range(bricks.size()):
		var configs: Array = bricks[row] 
		for col in range(configs.size()):
			var config = configs[col]
			var brick = brick_scene.instantiate()
			brick.hit.connect(func(): _on_brick_hit(brick))
			var texture_rect = brick.get_node("TextureRect") as TextureRect
			var size = texture_rect.size
			
			# Calculate total space available for gaps
			var total_gap_space = available_width - (MARGIN_HOR * 2) - (total_cols * size.x)
			var gap_x = total_gap_space / (total_cols - 1)
			
			# Position: left margin + half brick width + column * (brick width + gap)
			brick.position.x = boundaries.left + MARGIN_HOR + size.x/2 + col * (size.x + gap_x)
			brick.position.y = MARGIN_TOP + row * (GAP_Y + size.y)

			# Apply color
			texture_rect.modulate = config["color"]

			add_child(brick)

			# Randomly give powerup
			if ("power" in config and config.power) or randf() < 0.5:
				brick.enable_powerup()

func _on_mouse_click() -> void:
	if started: return
	started = true
	get_tree().call_group("balls", "start", Vector2(paddle.position.x, paddle.position.y - 24))

func _process(_delta: float) -> void:
	if not started:
		get_tree().call_group("balls", "set_deferred", "position", Vector2(paddle.position.x, paddle.position.y - 24))
		return

	# rotate paddle according to ball x distance to paddle's center
	# paddle.rotation = clampf(
	# 	deg_to_rad((ball.position.x - paddle.position.x) / 11),
	# 	deg_to_rad(-5),
	# 	deg_to_rad(5)
	# )

func _on_brick_hit(brick: Brick) -> void:
	total_bricks -= 1
	if total_bricks == 0:
		Global.freeze_ball = true
		get_tree().create_timer(2).timeout.connect(func():
			Global.next_level()
		)
	if not brick.has_powerup: return

	var powerup = null
	while powerup == last_powerup or powerup == null:
		powerup = Constants.POWERUPS[randi() % Constants.POWERUPS.size()]
			
	last_powerup = powerup

	match powerup:
		"extra-ball":
			total_balls += 1
			var new_ball = ball_scene.instantiate()
			add_child(new_ball)
			new_ball.start()
			new_ball.position.x = 200
			new_ball.position.y = paddle.position.y - 24
			Global.announce.emit(Constants.ANNOUNCE.POWERUP_EXTRA_BALL)

		"bigger-paddle":
			paddle.growy_boi()
			Global.announce.emit(Constants.ANNOUNCE.POWERUP_BIGGER_PADDLE)
				
		"slowdown":
			Global.on_slowdown()
			get_tree().call_group("balls", "slowdown")
			Global.announce.emit(Constants.ANNOUNCE.POWERUP_SLOWDOWN)
		"piercing":
			get_tree().call_group("balls", "enable_piercing")
			Global.announce.emit(Constants.ANNOUNCE.POWERUP_PIERCING)
		null:
			return

func _on_death_area_entered(body: Node2D) -> void:
	if body is Ball:
		total_balls -= 1
		body.queue_free()

	if total_balls == 0:
		Global._on_die()
		started = false
		paddle.rotation = 0
		var new_ball = ball_scene.instantiate()
		call_deferred("add_child", new_ball)
		total_balls = 1

func _on_update_score(score: int) -> void:
	score_label.text = str(score)

func _on_update_mult(mult: int) -> void:
	mult_label.text = 'x' + str(mult)
