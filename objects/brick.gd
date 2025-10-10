extends StaticBody2D
class_name Brick

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var texture: TextureRect = $TextureRect
@onready var powerup_label: Label = $PowerupLabel
@onready var explosion: Explosion = $Explosion
@onready var explosion_label: Label = $ExplosionLabel

const fragment_scene: PackedScene = preload("res://objects/brick_fragment.tscn")

var has_powerup = false
var has_explosion = false
var collision_dir = null
var brick_color: Color = Color.WHITE


func set_color(color: Color) -> void:
	texture.modulate = color
	brick_color = texture.modulate
	var s: ShaderMaterial = texture.material.duplicate()
	var shadow = brick_color
	shadow.a = 0.5
	shadow = shadow.darkened(0.5)
	s.set_shader_parameter("color", shadow)
	texture.material = s

func _process(delta: float) -> void:
	if collision_dir == null: return
	texture.position += collision_dir * delta *20
	texture.modulate.a -= 4.25 * delta

func change_width(width: float) -> void:
	var ratio: float = width / collision_shape.shape.size.x
	scale = Vector2.ONE * ratio


signal hit
func on_hit(dir: Vector2) -> void:
	if collision_dir != null: return
	Global._on_hit_brick()
	collision_dir = dir
	hit.emit()

	if has_explosion: 
		explosion.explode()

	texture.modulate = Color.WHITE
	powerup_label.hide()
	explosion_label.hide()
	collision_shape.disabled = true
	
	_create_shatter_fragments(dir)
	
	var timer = Timer.new()
	timer.wait_time = 5.0
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
	powerup_label.modulate = brick_color.darkened(0.35)
	powerup_label.show()
	has_powerup = true

func enable_explosion() -> void:
	explosion_label.modulate = brick_color.darkened(0.35)
	explosion_label.show()
	explosion.show()
	has_explosion = true
