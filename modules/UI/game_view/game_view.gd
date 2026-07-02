class_name game_view extends Control

func _ready() -> void:
	Events.pause_background_captured.connect(_on_pause_background_captured)
	Events.pause_background_cleared.connect(_on_pause_background_cleared)

func _on_pause_background_captured(tex: ImageTexture):
	$pause_bg.texture = tex

func _on_pause_background_cleared():
	$pause_bg.texture = null