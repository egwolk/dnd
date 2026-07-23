class_name PulseAnimator extends RefCounted

const PULSE_FACTOR := 1.0833
const PULSE_DURATION := 0.5

var target: CanvasItem
var base_scale: Vector2
var tween: Tween
var _is_playing := false

func _init(new_target: CanvasItem, new_base_scale: Vector2) -> void:
	target = new_target
	base_scale = new_base_scale

func play(delay: float = 0.0) -> void:
	if _is_playing:
		return
	_is_playing = true
	target.scale = base_scale

	if delay > 0.0:
		var delay_tween := target.create_tween()
		delay_tween.tween_interval(delay)
		await delay_tween.finished
		if not _is_playing or not is_instance_valid(target):
			return

	tween = target.create_tween().set_loops()
	tween.tween_property(target, "scale", base_scale * PULSE_FACTOR, PULSE_DURATION)
	tween.tween_property(target, "scale", base_scale, PULSE_DURATION)

func stop() -> void:
	_is_playing = false
	if tween and tween.is_valid():
		tween.kill()
	if is_instance_valid(target):
		target.scale = base_scale