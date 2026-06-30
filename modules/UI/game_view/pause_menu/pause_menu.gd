class_name pause_menu extends Control

func _ready() -> void:
	Events.pause_background_captured.connect(_on_pause_background_captured)
	pass

func _on_pause_background_captured(tex: ImageTexture):
	$pause_bg.texture = tex
