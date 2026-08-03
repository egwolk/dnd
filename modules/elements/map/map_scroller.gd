class_name MapScroller extends RefCounted

const SCROLL_SPEED := 50
const SCROLL_SMOOTHING := 10.0
const DRAG_THRESHOLD := 8.0
const OVERSCROLL_LIMIT := 140.0
const SPRING_BACK_SMOOTHING := 16.0
const WHEEL_RELEASE_MS := 120

var scroll_container: ScrollContainer
var visuals: Control
var overscroll_targets: Array[Control]


var scroll_target: float

var current_scroll: float
var last_overscroll_offset: float
var last_applied_scroll: int

var dragging := false
var drag_start_pos: Vector2
var drag_start_scroll: float
var drag_last_delta_y: float
var last_wheel_time_ms: int = -WHEEL_RELEASE_MS

var locked := false

func _init(p_scroll_container: ScrollContainer, p_visuals: Control, p_overscroll_targets: Array[Control] = []) -> void:
	scroll_container = p_scroll_container
	visuals = p_visuals
	overscroll_targets = p_overscroll_targets
	scroll_target = scroll_container.scroll_vertical
	current_scroll = scroll_target
	last_applied_scroll = scroll_container.scroll_vertical

func handle_input(event: InputEvent) -> bool:
	if locked:
		return false
	var handled := false

	if event.is_action_pressed("scroll_up"):
		_add_scroll_delta(-SCROLL_SPEED)
		last_wheel_time_ms = Time.get_ticks_msec()
		handled = true
	elif event.is_action_pressed("scroll_down"):
		_add_scroll_delta(SCROLL_SPEED)
		last_wheel_time_ms = Time.get_ticks_msec()
		handled = true
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_start_pos = event.position
			drag_start_scroll = scroll_target
			drag_last_delta_y = 0.0
		else:
			dragging = false
	elif event is InputEventMouseMotion and dragging:
		var motion_event := event as InputEventMouseMotion
		var delta_y := motion_event.position.y - drag_start_pos.y
		if absf(delta_y) > DRAG_THRESHOLD:
			var incremental := delta_y - drag_last_delta_y
			_add_scroll_delta(-incremental)
			drag_last_delta_y = delta_y
			handled = true

	return handled

func update(delta: float) -> void:
	if locked:
		return
	var max_scroll := get_max_scroll()
	var holding := dragging or _wheel_active()

	if not holding:
		if scroll_container.scroll_vertical != last_applied_scroll \
				and is_equal_approx(scroll_target, clampf(scroll_target, 0, max_scroll)):
			scroll_target = scroll_container.scroll_vertical
	
		scroll_target = clampf(scroll_target, 0, max_scroll)

	if not is_equal_approx(current_scroll, scroll_target):
		var out_of_bounds := current_scroll < 0 or current_scroll > max_scroll
		var smoothing := SPRING_BACK_SMOOTHING if out_of_bounds else SCROLL_SMOOTHING
		current_scroll = lerpf(current_scroll, scroll_target, smoothing * delta)
		if is_equal_approx(current_scroll, scroll_target):
			current_scroll = scroll_target

	var clamped_display := clampf(current_scroll, 0, max_scroll)
	scroll_container.scroll_vertical = roundi(clamped_display)
	last_applied_scroll = scroll_container.scroll_vertical

	var overscroll_offset := clamped_display - current_scroll
	if not is_equal_approx(overscroll_offset, last_overscroll_offset):
		var offset_delta := overscroll_offset - last_overscroll_offset
		for node in overscroll_targets:
			node.position.y += offset_delta
		last_overscroll_offset = overscroll_offset

func get_max_scroll() -> int:
	var v_scroll := scroll_container.get_v_scroll_bar()
	return maxi(0, int(v_scroll.max_value - v_scroll.page))

func set_target(value: float, snap: bool = false) -> void:
	var clamped := clampi(int(value), 0, get_max_scroll())
	scroll_target = clamped
	if snap:
		current_scroll = clamped
		scroll_container.scroll_vertical = clamped
		last_applied_scroll = clamped
		if last_overscroll_offset != 0.0:
			for node in overscroll_targets:
				node.position.y -= last_overscroll_offset
			last_overscroll_offset = 0.0

func animate_to(target: float, duration: float, host: Node) -> Tween:
	locked = true
	var max_scroll := get_max_scroll()
	var clamped := clampf(target, 0, max_scroll)
	scroll_target = clamped

	var tween := host.create_tween()
	tween.tween_method(_apply_animated_scroll, current_scroll, clamped, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(func(): locked = false)
	return tween

func _apply_animated_scroll(value: float) -> void:
	current_scroll = value
	var max_scroll := get_max_scroll()
	var clamped_display := clampf(current_scroll, 0, max_scroll)
	scroll_container.scroll_vertical = roundi(clamped_display)
	last_applied_scroll = scroll_container.scroll_vertical

func _wheel_active() -> bool:
	return Time.get_ticks_msec() - last_wheel_time_ms < WHEEL_RELEASE_MS

func _add_scroll_delta(delta_amount: float) -> void:
	var max_scroll := get_max_scroll()
	var resisted := delta_amount

	if scroll_target < 0 and delta_amount < 0:
		resisted *= _resistance(-scroll_target)
	elif scroll_target > max_scroll and delta_amount > 0:
		resisted *= _resistance(scroll_target - max_scroll)

	scroll_target = clampf(scroll_target + resisted, -OVERSCROLL_LIMIT, max_scroll + OVERSCROLL_LIMIT)

func _resistance(current_excess: float) -> float:
	return clampf(1.0 - current_excess / OVERSCROLL_LIMIT, 0.0, 1.0)