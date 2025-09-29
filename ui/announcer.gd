extends CanvasLayer

@onready var bg: TextureRect = $BG
@onready var label: Label = %Label
@onready var player: AnimationPlayer = %AnimationPlayer

var params_map: Dictionary = {
	Constants.ANNOUNCE.COMBO_AMAZING: {
		"text": "amazing!",
		"is_rainbow": true,
	},
	Constants.ANNOUNCE.COMBO_INCREDIBLE: {
		"text": "*incredible*",
		"is_rainbow": true,
	},
	Constants.ANNOUNCE.COMBO_COMBO: {
		"text": "c-c-combo!",
		"is_rainbow": true,
	},
	Constants.ANNOUNCE.COMBO_GOOD_JOB: {
		"text": "good job!!",
		"is_rainbow": true,
	},
	Constants.ANNOUNCE.COMBO_NICE: {
		"text": "niiiiiiceeeee",
		"is_rainbow": true,
	},
	Constants.ANNOUNCE.COMBO_YOU_ROCK: {
		"text": "you ROCK!",
		"is_rainbow": true,
	},
	Constants.ANNOUNCE.COMBO_UNSTOPPABLE: {
		"text": "unSTOPPABLE!",
		"is_rainbow": true,
	},
	Constants.ANNOUNCE.POWERUP_EXTRA_BALL: {
		"text": "extra ball!",
		"color": Constants.COLORS["cornflower"]
	},
	Constants.ANNOUNCE.POWERUP_BIGGER_PADDLE: {
		"text": "BIG BOI PADDLE",
		"color": Constants.COLORS["salmon"]
	},
	Constants.ANNOUNCE.POWERUP_SLOWDOWN: {
		"text": "slowdown!",
		"color": Constants.COLORS["purple"]
	},
}

var queue: Array = []

func _ready() -> void:
	Global.announce.connect(_on_announce)

var tween: Tween
func _on_announce(id: Constants.ANNOUNCE) -> void:
	if player.is_playing(): 
		player.speed_scale = 2
		queue.append(id)
		return

	if tween: tween.kill()

	var params: Dictionary = params_map.get(id)
	if not params: return
	
	label.text = params.text
	if params.get("is_rainbow", false):
		bg.modulate = Color.BLACK.lightened(0.1)
		# text should cycle through rainbow colors
		tween = get_tree().create_tween()
		tween.set_loops()  # Infinite loop
		var start_hue := 0.0
		var end_hue := 1.0  # wraps back to red
		var duration := 6.0 # full cycle duration

		tween.tween_method(
			func(h: float):
				var c = Color.from_hsv(h, 0.4, 0.9)
				label.label_settings.font_color = c,
			start_hue,
			end_hue,
			duration
		)
	else:
		label.text = params.text
		label.label_settings.font_color = params.color
		if params.color.get_luminance() > 0.6:
			bg.modulate = params.color.darkened(0.25)
		else:
			bg.modulate = params.color.lightened(0.85)

	player.play("announce")
	get_tree().create_timer(0.01).timeout.connect(show)


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	hide()
	var id = queue.pop_front()
	if id:
		_on_announce(id)
	else: 
		player.speed_scale = 1
