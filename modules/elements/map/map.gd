class_name Map extends Control

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
var line_renderer: MapLineRenderer
var scroller: MapScroller

const BOTTOM_MARGIN := 200
const TOP_MARGIN := MapGenerator.Y_DIST + 200
const BACKGROUND_HORIZONTAL_PADDING := 150
const EXTRA_SCROLL_PADDING := 100
const INTRO_SCROLL_DURATION := 1.6

func _ready() -> void:
	line_renderer = MapLineRenderer.new(lines)
	scroller = MapScroller.new(scroll_container, visuals, [background, lines, steps] as Array[Control])
	Events.selected.connect(_on_map_node_selected)
	Events.path_chosen.connect(_on_map_node_path_chosen)

func _input(event: InputEvent) -> void:
	if scroller.handle_input(event):
		get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	scroller.update(delta)


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

func lock_scroll() -> void:
	scroller.locked = true
	scroll_container.mouse_filter = Control.MOUSE_FILTER_IGNORE

func unlock_scroll() -> void:
	scroller.locked = false
	scroll_container.mouse_filter = Control.MOUSE_FILTER_STOP

func scroll_to_current_node(prefer_current_node: bool = false) -> void:
	scroller.set_target(_compute_target_scroll(prefer_current_node), true)

func play_intro_scroll(prefer_current_node: bool = false) -> void:
	var target_scroll := _compute_target_scroll(prefer_current_node)
	scroller.set_target(0, true)
	var tween := scroller.animate_to(target_scroll, INTRO_SCROLL_DURATION, self)
	await tween.finished

func _compute_target_scroll(prefer_current_node: bool = false) -> int:
	var max_scroll := scroller.get_max_scroll()
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

	return clampi(target_scroll, 0, max_scroll)

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