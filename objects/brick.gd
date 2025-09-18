extends StaticBody2D
class_name Brick

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var texture: TextureRect = $TextureRect
@onready var powerup_label: Label = $PowerupLabel

const fragment_scene: PackedScene = preload("res://objects/brick_fragment.tscn")

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
	# Create 5-8 fragments using different pieces from the broken texture
	var fragment_count = randi_range(3, 8)
	
	for i in range(fragment_count):
		var fragment = fragment_scene.instantiate()
		get_parent().add_child(fragment)
		fragment.setup(self, collision_direction)
		

func enable_powerup() -> void:
	powerup_label.show()
	powerup = Global.POWERUPS[randi() % Global.POWERUPS.size()]
