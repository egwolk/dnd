class_name PulseAnimator extends RefCounted

const PULSE_FACTOR := 1.0833
const PULSE_DURATION := 0.5

var target: CanvasItem
var base_scale: Vector2
var tween: Tween

func _init(new_target: CanvasItem, new_base_scale: Vector2) -> void:
	target = new_target
	base_scale = new_base_scale

func play() -> void:
	if tween and tween.is_valid():
		return 
	target.scale = base_scale
	tween = target.create_tween().set_loops()
	tween.tween_property(target, "scale", base_scale * PULSE_FACTOR, PULSE_DURATION)
	tween.tween_property(target, "scale", base_scale, PULSE_DURATION)

func stop() -> void:
	if tween and tween.is_valid():
		tween.kill()
	target.scale = base_scale