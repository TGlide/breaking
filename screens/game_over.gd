extends Control

@onready var ScoreLabel: Label = $VBoxContainer/ScoreLabel
@onready var HiScoreLabel: Label = $VBoxContainer/HiScoreLabel

const save_path = "user://score.save"
var best = 0

func save_score():
	if Global.score < best: return
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(Global.score)

func load_score():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		best = file.get_var()
	else:
		best = 0


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	load_score()
	ScoreLabel.text = "score: " + str(Global.score)
	HiScoreLabel.text = "hi-score: " + str(best)
	save_score()
	Global.score = 0

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
			_on_ok_button_pressed()

func _on_ok_button_pressed() -> void:
	Global.change_screen.emit(Global.TITLE_SCREEN)
