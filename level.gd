extends Node
class_name Level

const brick_scene: PackedScene = preload("res://objects/brick.tscn")

@onready var paddle: Paddle = $Paddle
@onready var ball: Ball = $Ball
@onready var score_label: Label = $Score
@onready var mult_label: Label = $Multiplier

var COLORS = {
	"salmon": Color(0.917647, 0.384314, 0.384314, 1),
	"green": Color(0.670588, 0.866667, 0.392157, 1),
	"blue": Color(0.682353, 0.886275, 1, 1),
	"orange": Color(1, 0.721569, 0.47451, 1),
	"purple": Color(0.427451, 0.501961, 0.980392, 1),
	"yellow": Color.html("#fcef8d"),
}

const MARGIN_HOR = 72
const MARGIN_TOP = 116
const GAP_Y = 4
var BRICKS = [
	# Row 1
	[
		{ "color": COLORS.salmon },
		{ "color": COLORS.salmon },
		{ "color": COLORS.salmon },
		{ "color": COLORS.salmon },
		{ "color": COLORS.salmon },
		{ "color": COLORS.salmon },
		{ "color": COLORS.salmon },
		{ "color": COLORS.salmon },
	],
	# Row 2
	[
		{ "color": COLORS.orange },
		{ "color": COLORS.orange },
		{ "color": COLORS.orange },
		{ "color": COLORS.orange },
		{ "color": COLORS.orange },
		{ "color": COLORS.orange },
		{ "color": COLORS.orange },
		{ "color": COLORS.orange },
	],
	# Row 3
	[
		{ "color": COLORS.yellow },
		{ "color": COLORS.yellow },
		{ "color": COLORS.yellow },
		{ "color": COLORS.yellow },
		{ "color": COLORS.yellow },
		{ "color": COLORS.yellow },
		{ "color": COLORS.yellow },
		{ "color": COLORS.yellow },
	],
	# Row 4
	[
		{ "color": COLORS.green },
		{ "color": COLORS.green },
		{ "color": COLORS.green },
		{ "color": COLORS.green },
		{ "color": COLORS.green },
		{ "color": COLORS.green },
		{ "color": COLORS.green },
		{ "color": COLORS.green },
	],
	# Row 5
	[
		{ "color": COLORS.purple },
		{ "color": COLORS.purple },
		{ "color": COLORS.purple },
		{ "color": COLORS.purple },
		{ "color": COLORS.purple },
		{ "color": COLORS.purple },
		{ "color": COLORS.purple },
		{ "color": COLORS.purple },
	],
	# Row 6
	[
		{ "color": COLORS.blue },
		{ "color": COLORS.blue },
		{ "color": COLORS.blue },
		{ "color": COLORS.blue },
		{ "color": COLORS.blue },
		{ "color": COLORS.blue },
		{ "color": COLORS.blue },
		{ "color": COLORS.blue },
	],
]

var started = false

func _ready() -> void:
	Global.update_score.connect(_on_update_score)
	Global.update_mult.connect(_on_update_mult)
	Global.mouse_click.connect(_on_mouse_click)

	var boundaries = Global.calculate_boundaries()
	var available_width = boundaries.right - boundaries.left

	for row in range(BRICKS.size()):
		var configs: Array = BRICKS[row] 
		for col in range(configs.size()):
			var brick = brick_scene.instantiate()
			var texture_rect = brick.get_node("TextureRect") as TextureRect
			var size = texture_rect.size
			
			# Calculate total space available for gaps
			var total_gap_space = available_width - (MARGIN_HOR * 2) - (configs.size() * size.x)
			var gap_x = total_gap_space / (configs.size() - 1)
			
			# Position: left margin + half brick width + column * (brick width + gap)
			brick.position.x = boundaries.left + MARGIN_HOR + size.x/2 + col * (size.x + gap_x)
			brick.position.y = MARGIN_TOP + row * (GAP_Y + size.y)

			# Apply color
			texture_rect.modulate = configs[col]["color"]
			brick.get_node("ChunkParticles").modulate = configs[col]["color"]
			add_child(brick)

func _on_mouse_click() -> void:
	if started: return
	started = true
	ball.start()

func _process(_delta: float) -> void:
	if not started:
		ball.position.x = paddle.position.x
		ball.position.y = paddle.position.y - 24 
		return

	# rotate paddle according to ball x distance to paddle's center
	paddle.rotation = clampf(
		deg_to_rad((ball.position.x - paddle.position.x) / 11),
		deg_to_rad(-5),
		deg_to_rad(5)
	)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Ball:
		Global._on_die()
		started = false
		paddle.rotation = 0
		ball.stop()

func _on_update_score(score: int) -> void:
	score_label.text = str(score)

func _on_update_mult(mult: int) -> void:
	mult_label.text = 'x' + str(mult)
