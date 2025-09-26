extends Node

var COLORS = {
	"salmon": Color.html("#ea6262"),
	"green": Color.html("#abdd64"),
	"blue": Color.html("#aee2ff"),
	"orange": Color.html("#ffb879"),
	"cornflower": Color.html("#6d80fa"),
	"yellow": Color.html("#fcef8d"),
	"purple": Color.html("#8465ec"),
}


enum ANNOUNCE {
	# Combos
	COMBO_AMAZING,
	COMBO_INCREDIBLE,
	COMBO_COMBO,
	COMBO_GOOD_JOB,
	COMBO_NICE,
	COMBO_YOU_ROCK,
	COMBO_UNSTOPPABLE,
	# Powerups
	POWERUP_EXTRA_BALL,
	POWERUP_BIGGER_PADDLE
}

const CONFIG_PATH = "user://config.cfg"
