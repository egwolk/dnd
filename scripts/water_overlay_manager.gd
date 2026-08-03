extends Node

const WATER_OVERLAY_SCENE := preload("res://modules/UI/common_shaders/water_bg_overlay.tscn")

var _overlay: Control


func _ready() -> void:
	_overlay = WATER_OVERLAY_SCENE.instantiate()
	_overlay.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_overlay)


func show_in(target: Control) -> void:
	if _overlay.get_parent() != target:
		_overlay.reparent(target, false)
		target.move_child(_overlay, 0)
		_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.visible = true
	await get_tree().process_frame

func hide_overlay() -> void:
	_overlay.visible = false

func reclaim() -> void:
	if _overlay.get_parent() != self:
		_overlay.reparent(self, false)
	_overlay.visible = false