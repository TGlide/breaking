extends Node2D
class_name Main

@onready var sub_viewport_container: SubViewportContainer = $SVC
@onready var sub_viewport: SubViewport = $SVC/SubView
@onready var BG: TextureRect = $Background
@onready var border: TextureRect = $Border
@onready var fps_counter: Label = $FpsCounter

var current_scene: Node

const RES_MULT = 6
@export var margin: Vector2 = Vector2(128, 128)  # Configurable margin
@export var padding: Vector2 = Vector2(64, 64)  # Configurable padding

@onready var base_view_size = Vector2( 
	sub_viewport.get_visible_rect().size.x * RES_MULT,
	sub_viewport.get_visible_rect().size.y * RES_MULT
)

func _ready() -> void:
	Global.change_screen.connect(_on_change_screen)
	sub_viewport.size_2d_override = sub_viewport.size
	sub_viewport.size = sub_viewport.size * RES_MULT
	current_scene = sub_viewport.get_child(0)
	get_viewport().size_changed.connect(reprocess)
	# wait for viewport to be ready
	await get_tree().process_frame
	reprocess()

func _on_change_screen(scene: PackedScene) -> void:
	current_scene.queue_free()
	current_scene = scene.instantiate()
	sub_viewport.add_child(current_scene)


func _process(_delta: float) -> void:
	fps_counter.text = str(Engine.get_frames_per_second())

func reprocess() -> void:
	var view_aspect_ratio = base_view_size.x / base_view_size.y
	var win_size = get_viewport_rect().size
	var available_size = win_size - margin * 2  # Account for margin on both sides
	var win_aspect_ratio = available_size.x / available_size.y

	# if wider, maximize height
	if win_aspect_ratio > view_aspect_ratio:
		var ns = available_size.y / base_view_size.y
		sub_viewport_container.scale = Vector2(ns, ns)
	else:
		var ns = available_size.x / base_view_size.x
		sub_viewport_container.scale = Vector2(ns, ns)

	# center the viewport
	var view_rect = sub_viewport_container.get_rect()
	sub_viewport_container.position.x = (win_size.x / 2) - (view_rect.size.x / 2)
	sub_viewport_container.position.y = (win_size.y / 2) - (view_rect.size.y / 2)

	border.size.x = view_rect.size.x + padding.x 
	border.size.y = view_rect.size.y + padding.y 
	border.position.x = (win_size.x / 2) - (border.size.x / 2)
	border.position.y = (win_size.y / 2) - (border.size.y / 2)

	BG.size = win_size
