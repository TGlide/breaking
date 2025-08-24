extends Node2D
class_name Main

@onready var sub_viewport_container: SubViewportContainer = $SVC
@onready var sub_viewport: SubViewport = $SVC/SubView
@onready var BG: TextureRect = $Background

const RES_MULT = 2

@onready var base_view_size = Vector2( 
	sub_viewport.get_visible_rect().size.x * RES_MULT,
	sub_viewport.get_visible_rect().size.y * RES_MULT
)

func _ready() -> void:
	sub_viewport.size_2d_override = sub_viewport.size
	sub_viewport.size = sub_viewport.size * RES_MULT

func _process(_delta: float) -> void:
	var view_aspect_ratio = base_view_size.x / base_view_size.y
	var win_size = get_viewport_rect().size
	var win_aspect_ratio = win_size.x / win_size.y

	# if wider, maximize height
	if win_aspect_ratio > view_aspect_ratio:
		sub_viewport_container.scale.y = win_size.y / base_view_size.y
		sub_viewport_container.scale.x = win_size.y * view_aspect_ratio / base_view_size.y
	else:
		sub_viewport_container.scale.x = win_size.x / base_view_size.x
		sub_viewport_container.scale.y = win_size.x * view_aspect_ratio / base_view_size.x

	# center the viewport
	var view_rect = sub_viewport_container.get_rect()
	sub_viewport_container.position.x = (win_size.x / 2) - (view_rect.size.x / 2)
	sub_viewport_container.position.y = (win_size.y / 2) - (view_rect.size.y / 2)

	BG.size = win_size
	pass
