extends Node2D
class_name Main

@onready var sub_viewport_container: SubViewportContainer = $SubViewportContainer
@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport
@onready var BG: TextureRect = $Background

@onready var base_win_size = Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height")
)
@onready var base_view_size = Vector2( 
	sub_viewport.get_visible_rect().size.x,
	sub_viewport.get_visible_rect().size.y 
)

func _process(_delta: float) -> void:
	var view_aspect_ratio = base_view_size.x / base_view_size.y
	var base_win_aspect_ratio = base_win_size.x / base_win_size.y
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
