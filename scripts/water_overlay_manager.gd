extends Node

const WATER_OVERLAY_SCENE := preload("res://modules/UI/common_shaders/water_bg_overlay.tscn")
var _source: Control
var _display: ColorRect
var _display_material: ShaderMaterial


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	_source = WATER_OVERLAY_SCENE.instantiate()
	_source.visible = false
	_source.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_source)

	var bubbles_vp: SubViewport = _source.get_node("bubbles")
	var bubbles_far_vp: SubViewport = _source.get_node("bubbles_far")
	var caustic_vp: SubViewport = _source.get_node("caustic")
	var caustic2_vp: SubViewport = _source.get_node("caustic2")

	var source_effect: ColorRect = _source.get_node("underwater_effect")
	_display_material = source_effect.material.duplicate()

	_display_material.set_shader_parameter("bubbles_far", bubbles_far_vp.get_texture())
	_display_material.set_shader_parameter("bubble_texture", bubbles_vp.get_texture())
	_display_material.set_shader_parameter("caustic_texture", caustic_vp.get_texture())
	_display_material.set_shader_parameter("caustic_texture2", caustic2_vp.get_texture())

	_display = ColorRect.new()
	_display.name = "water_bg_display"
	_display.material = _display_material
	_display.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_display.visible = false
	_display.set_anchors_preset(Control.PRESET_FULL_RECT)


func show_in(target: Control, index: int = 0) -> void:
	if _display.get_parent() == target:
		_display.set_anchors_preset(Control.PRESET_FULL_RECT)
		target.move_child(_display, index)
		_display.visible = true
		return

	if _display.get_parent():
		_display.get_parent().remove_child(_display)

	call_deferred("_show_in_deferred", target, index)


func _show_in_deferred(target: Control, index: int) -> void:
	if not is_instance_valid(target):
		return

	if _display.get_parent():
		_display.get_parent().remove_child(_display)

	target.add_child(_display)
	_display.set_anchors_preset(Control.PRESET_FULL_RECT)
	target.move_child(_display, index)
	_display.visible = true

func hide_overlay() -> void:
	_display.visible = false

func reclaim() -> void:
	_display.visible = false
	if _display.get_parent() and _display.get_parent() != self:
		_display.get_parent().remove_child(_display)
	
	if _display.get_parent() != self:
		add_child.call_deferred(_display)