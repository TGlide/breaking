extends HBoxContainer

var config: ConfigFile = ConfigFile.new()
var err := config.load(Global.CONFIG_PATH)

@onready var sound_btn: Button = $SoundBtn
@onready var music_btn: Button = $MusicBtn

func _on_update() -> void:
	var is_sound_on = config.get_value("sound", "enabled", true)
	sound_btn.text = "sound " + ("on" if is_sound_on else "off")
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), not is_sound_on)
	
	var is_music_on = config.get_value("music", "enabled", true)
	music_btn.text = "music " + ("on" if is_music_on else "off")
	AudioServer.set_bus_mute(AudioServer.get_bus_index("BGM"), not is_music_on)

func _ready() -> void:
	_on_update()

func _on_sound_btn_pressed() -> void:
	config.set_value("sound", "enabled", not config.get_value("sound", "enabled", true))
	config.save(Global.CONFIG_PATH)
	_on_update()

func _on_music_btn_pressed() -> void:
	config.set_value("music", "enabled", not config.get_value("music", "enabled", true))
	config.save(Global.CONFIG_PATH)
	_on_update()
