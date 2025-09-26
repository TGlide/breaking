extends CanvasLayer

@onready var bg: TextureRect = $BG
@onready var label: Label = %Label
@onready var player: AnimationPlayer = %AnimationPlayer

var queue: Array = []

func _ready() -> void:
	Global.announce.connect(_on_announce)

func _on_announce(text: String, color: Color) -> void:
	if player.is_playing(): 
		player.speed_scale = 2
		queue.append({"text": text, "color": color})
		return

	label.text = text
	label.label_settings.font_color = color
	if color.get_luminance() > 0.6:
		bg.modulate = color.darkened(0.25)
	else:
		bg.modulate = color.lightened(0.85)
	player.play("announce")


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	var params = queue.pop_front()
	if params:
		_on_announce(params['text'], params['color'])
	else: 
		player.speed_scale = 1
