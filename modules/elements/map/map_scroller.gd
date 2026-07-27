class_name MapScroller extends RefCounted

const SCROLL_SPEED := 50
const SCROLL_SMOOTHING := 10.0
const DRAG_THRESHOLD := 8.0

var scroll_container: ScrollContainer
var visuals: Control

var scroll_target: float
var last_applied_scroll: int
var dragging := false
var drag_start_pos: Vector2
var drag_start_scroll: float

func _init(p_scroll_container: ScrollContainer, p_visuals: Control) -> void:
	scroll_container = p_scroll_container
	visuals = p_visuals
	scroll_target = scroll_container.scroll_vertical
	last_applied_scroll = scroll_container.scroll_vertical

func handle_input(event: InputEvent) -> bool:
	var handled := false

	if event.is_action_pressed("scroll_up"):
		scroll_target -= SCROLL_SPEED
		handled = true
	elif event.is_action_pressed("scroll_down"):
		scroll_target += SCROLL_SPEED
		handled = true
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_start_pos = event.position
			drag_start_scroll = scroll_target
		else:
			dragging = false
	elif event is InputEventMouseMotion and dragging:
		var motion_event := event as InputEventMouseMotion
		var delta_y := motion_event.position.y - drag_start_pos.y
		if absf(delta_y) > DRAG_THRESHOLD:
			scroll_target = drag_start_scroll - delta_y
			handled = true

	scroll_target = clampf(scroll_target, 0, get_max_scroll())
	return handled

func update(delta: float) -> void:
	if scroll_container.scroll_vertical != last_applied_scroll:
		scroll_target = scroll_container.scroll_vertical

	if not is_equal_approx(scroll_container.scroll_vertical, scroll_target):
		scroll_container.scroll_vertical = roundi(
			lerpf(scroll_container.scroll_vertical, scroll_target, SCROLL_SMOOTHING * delta)
		)

	last_applied_scroll = scroll_container.scroll_vertical

func get_max_scroll() -> int:
	return int(visuals.custom_minimum_size.y - scroll_container.size.y)

func set_target(value: float, snap: bool = false) -> void:
	var clamped := clampi(int(value), 0, get_max_scroll())
	scroll_target = clamped
	if snap:
		scroll_container.scroll_vertical = clamped
		last_applied_scroll = clamped