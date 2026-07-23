class_name PulseAnimator extends RefCounted

const PULSE_FACTOR := 1.2
const PULSE_DURATION := 0.5
const EASE_DURATION := 0.25

var target: CanvasItem
var base_scale: Vector2
var modulate_min: float
var modulate_max: float
var tween: Tween
var _is_playing := false

func _init(new_target: CanvasItem, new_base_scale: Vector2, new_modulate_min: float, new_modulate_max: float) -> void:
	target = new_target
	base_scale = new_base_scale
	modulate_min = new_modulate_min
	modulate_max = new_modulate_max

func play(delay: float = 0.0) -> void:
	if _is_playing:
		return
	_is_playing = true
	target.scale = base_scale
	target.modulate.v = modulate_min

	if delay > 0.0:
		var delay_tween := target.create_tween()
		delay_tween.tween_interval(delay)
		await delay_tween.finished
		if not _is_playing or not is_instance_valid(target):
			return

	tween = target.create_tween().set_loops()
	tween.tween_property(target, "scale", base_scale * PULSE_FACTOR, PULSE_DURATION)
	tween.parallel().tween_property(target, "modulate:v", modulate_max, PULSE_DURATION)
	tween.tween_property(target, "scale", base_scale, PULSE_DURATION)
	tween.parallel().tween_property(target, "modulate:v", modulate_min, PULSE_DURATION)

func pause() -> void:
	_is_playing = false
	if tween and tween.is_valid():
		tween.kill()

func stop(end_modulate: float = -1.0, animate: bool = true) -> void:
	_is_playing = false
	if tween and tween.is_valid():
		tween.kill()
	if not is_instance_valid(target):
		return

	var target_modulate := modulate_min if end_modulate < 0.0 else end_modulate

	if not animate:
		target.scale = base_scale
		target.modulate.v = target_modulate
		return

	var ease_tween := target.create_tween()
	ease_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	ease_tween.set_parallel(true)
	ease_tween.tween_property(target, "scale", base_scale, EASE_DURATION)
	ease_tween.tween_property(target, "modulate:v", target_modulate, EASE_DURATION)