extends StaticBody2D
class_name Brick

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var texture: TextureRect = $TextureRect
@onready var powerup_label: Label = $PowerupLabel

const fragment_scene: PackedScene = preload("res://objects/brick_fragment.tscn")
const broken_texture: Texture2D = preload("res://assets/brick-broken.aseprite")

var powerup = null
var collision_dir = null
var brick_color: Color = Color.WHITE

func _ready():
	brick_color = texture.modulate

func _process(delta: float) -> void:
	if collision_dir == null: return
	texture.position += collision_dir * delta *30
	texture.modulate.a -= 5 * delta

signal hit
func on_hit(dir: Vector2) -> void:
	hit.emit()
	collision_dir = dir

	texture.modulate = Color.WHITE
	powerup_label.hide()
	collision_shape.disabled = true
	
	_create_shatter_fragments(dir)
	
	var timer = Timer.new()
	timer.wait_time = 0.1
	timer.one_shot = true
	timer.timeout.connect(queue_free)
	add_child(timer)
	timer.start()

func _create_shatter_fragments(collision_direction: Vector2):
	var brick_size = texture.size
	
	# Create 5-8 fragments using different pieces from the broken texture
	var fragment_count = randi_range(5, 8)
	var used_indices = []
	
	for i in range(fragment_count):
		var fragment = fragment_scene.instantiate()
		
		# Pick a random fragment piece (0-7)
		var fragment_index = randi() % 8
		while fragment_index in used_indices and used_indices.size() < 8:
			fragment_index = randi() % 8
		used_indices.append(fragment_index)
		
		# Position fragments randomly within the brick area
		var fragment_pos = global_position + Vector2(
			randf_range(-brick_size.x * 0.3, brick_size.x * 0.3),
			randf_range(-brick_size.y * 0.3, brick_size.y * 0.3)
		)
		
		# Calculate velocity based on collision direction
		var base_speed = randf_range(150, 350)
		var spread_angle = randf_range(-70, 70)
		var velocity_angle = collision_direction.angle() + deg_to_rad(spread_angle)
		
		var initial_velocity = Vector2(
			cos(velocity_angle) * base_speed,
			sin(velocity_angle) * base_speed - randf_range(50, 150)
		)
		
		var angular_vel = randf_range(-10, 10)
		
		get_parent().add_child(fragment)
		
		fragment.setup(
			broken_texture,
			brick_color,
			fragment_index,
			fragment_pos,
			initial_velocity,
			angular_vel
		)
		
		# Set death area position (below the paddle area)
		fragment.death_y = 594  # Match the DeathArea position from level.tscn

func enable_powerup() -> void:
	powerup_label.show()
	powerup = Global.POWERUPS[randi() % Global.POWERUPS.size()]
