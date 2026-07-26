class_name Map extends Control

const SCROLL_SPEED := 50
const SCROLL_SMOOTHING := 10.0
const DRAG_THRESHOLD := 8.0

const MAP_NODE = preload("res://modules/elements/map/map_node_button.tscn")

@onready var map_generator: MapGenerator = %map_generator
@onready var lines: Control = %map_lines
@onready var steps: Control = %map_nodes
@onready var visuals: Control = $mapContainer/MarginContainer/ScrollContainer/map_visuals
@onready var scroll_container: ScrollContainer = $mapContainer/MarginContainer/ScrollContainer
@onready var background: NinePatchRect = $mapContainer/MarginContainer/ScrollContainer/map_visuals/NinePatchRect

var map_data: Array[Array]
var steps_taken: int
var last_node: MapNode
var camera_edge_y: float
var line_renderer: MapLineRenderer
var scroll_target: float
var last_applied_scroll: int
var dragging := false
var drag_start_pos: Vector2
var drag_start_scroll: float

const BOTTOM_MARGIN := 200
const TOP_MARGIN := MapGenerator.Y_DIST + 200
const BACKGROUND_HORIZONTAL_PADDING := 150
const EXTRA_SCROLL_PADDING := 100

func _ready() -> void:
	line_renderer = MapLineRenderer.new(lines)
	Events.selected.connect(_on_map_node_selected)
	Events.path_chosen.connect(_on_map_node_path_chosen)
	scroll_target = scroll_container.scroll_vertical
	last_applied_scroll = scroll_container.scroll_vertical

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("scroll_up"):
		scroll_target -= SCROLL_SPEED
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("scroll_down"):
		scroll_target += SCROLL_SPEED
		get_viewport().set_input_as_handled()
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
			get_viewport().set_input_as_handled()

	scroll_target = clampf(scroll_target, 0, _get_max_scroll())

func _process(delta: float) -> void:
	if scroll_container.scroll_vertical != last_applied_scroll:
		scroll_target = scroll_container.scroll_vertical

	if not is_equal_approx(scroll_container.scroll_vertical, scroll_target):
		scroll_container.scroll_vertical = roundi(
			lerpf(scroll_container.scroll_vertical, scroll_target, SCROLL_SMOOTHING * delta)
		)

	last_applied_scroll = scroll_container.scroll_vertical
func _get_max_scroll() -> int:
	return int(visuals.custom_minimum_size.y - scroll_container.size.y)

func generate_new_map() -> void:
	steps_taken = 0
	map_data = map_generator.generate_map()
	create_map()

func create_map() -> void:
	var map_width_pixels := MapGenerator.X_DIST * (MapGenerator.MAP_WIDTH - 1)
	var map_height_pixels := MapGenerator.Y_DIST * (MapGenerator.STEPS - 1)
	var viewport_width := get_viewport_rect().size.x
	var x_offset := (viewport_width - map_width_pixels) / 2

	steps.position = Vector2(x_offset, map_height_pixels + TOP_MARGIN +EXTRA_SCROLL_PADDING)
	lines.position = Vector2(x_offset, map_height_pixels + TOP_MARGIN + EXTRA_SCROLL_PADDING)

	background.position.x = x_offset - BACKGROUND_HORIZONTAL_PADDING
	background.position.y = EXTRA_SCROLL_PADDING
	background.size.x = map_width_pixels + BACKGROUND_HORIZONTAL_PADDING * 2
	background.size.y = map_height_pixels + BOTTOM_MARGIN + TOP_MARGIN

	for current_node: Array in map_data:
		for step: MapNode in current_node:
			if step.next_nodes.size() > 0:
				_spawn_node(step)

	var middle := floori(MapGenerator.MAP_WIDTH * 0.5)
	_spawn_node(map_data[MapGenerator.STEPS - 1][middle])

	visuals.custom_minimum_size = Vector2(map_width_pixels, map_height_pixels + BOTTOM_MARGIN + TOP_MARGIN + EXTRA_SCROLL_PADDING * 2)
	background.size.y = map_height_pixels + BOTTOM_MARGIN + TOP_MARGIN

	line_renderer.reveal_traveled_path(map_data)

	await get_tree().process_frame
	scroll_to_current_node()

func scroll_to_current_node(prefer_current_node: bool = false) -> void:
	var max_scroll := int(visuals.custom_minimum_size.y - scroll_container.size.y)
	var target_scroll: int

	if prefer_current_node and last_node:
		var node_y := steps.position.y + last_node.position.y
		target_scroll = int(node_y - scroll_container.size.y * 0.5)
	else:
		var available_nodes: Array[MapNodeButton] = []
		for map_node: MapNodeButton in steps.get_children():
			if map_node.available:
				available_nodes.append(map_node)

		if available_nodes.size() > 0:
			var avg_y := 0.0
			for map_node in available_nodes:
				avg_y += map_node.position.y
			avg_y /= available_nodes.size()
			target_scroll = int(steps.position.y + avg_y - scroll_container.size.y * 0.5)
		elif last_node:
			var node_y := steps.position.y + last_node.position.y
			target_scroll = int(node_y - scroll_container.size.y * 0.5)
		else:
			target_scroll = max_scroll

	target_scroll = clampi(target_scroll, 0, max_scroll)
	scroll_target = target_scroll
	scroll_container.scroll_vertical = target_scroll
	last_applied_scroll = target_scroll

func unlock_node(which_node: int = steps_taken) -> void:
	for map_node: MapNodeButton in steps.get_children():
		if map_node.step.row == which_node:
			map_node.available = true

func unlock_next_nodes() -> void:
	for map_node: MapNodeButton in steps.get_children():
		if last_node.next_nodes.has(map_node.step):
			map_node.available = true

func _spawn_node(step: MapNode) -> void:
	var new_map_node := MAP_NODE.instantiate() as MapNodeButton
	steps.add_child(new_map_node)
	new_map_node.step = step
	line_renderer.connect_nodes(step)

func _on_map_node_path_chosen(step: MapNode) -> void:
	for map_node: MapNodeButton in steps.get_children():
		if map_node.step.row == step.row:
			map_node.available = false

	if last_node:
		line_renderer.animate(last_node, step)
	else:
		Events.line_animation_finished.emit(step)

func _on_map_node_selected(step: MapNode) -> void:
	for map_node: MapNodeButton in steps.get_children():
		if map_node.step.row == step.row:
			map_node.available = false

	last_node = step
	steps_taken += 1
	unlock_next_nodes()

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and is_node_ready():
		for map_node: MapNodeButton in steps.get_children():
			if visible:
				map_node.resume_pulse()
			else:
				map_node.pause_pulse()
