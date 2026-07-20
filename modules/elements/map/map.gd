class_name Map extends Control

const SCROLL_SPEED := 15

const MAP_NODE = preload("res://modules/elements/map/map_node_button.tscn")

@onready var map_generator: MapGenerator = %map_generator
@onready var lines: Control = %map_lines
@onready var steps: Control = %map_nodes
@onready var visuals: Control = $PanelContainer/MarginContainer/ScrollContainer/map_visuals
@onready var scroll_container: ScrollContainer = $PanelContainer/MarginContainer/ScrollContainer

var map_data: Array[Array]
var steps_taken: int
var last_node: MapNode
var camera_edge_y: float
var line_renderer: MapLineRenderer

const BOTTOM_MARGIN := 200
const TOP_MARGIN := MapGenerator.Y_DIST + 200

func _ready() -> void:
	line_renderer = MapLineRenderer.new(lines)
	Events.selected.connect(_on_map_node_selected)
	Events.path_chosen.connect(_on_map_node_path_chosen)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("scroll_up"):
		scroll_container.scroll_vertical -= SCROLL_SPEED
	elif event.is_action_pressed("scroll_down"):
		scroll_container.scroll_vertical += SCROLL_SPEED

func generate_new_map() -> void:
	steps_taken = 0
	map_data = map_generator.generate_map()
	create_map()

func create_map() -> void:
	var map_width_pixels := MapGenerator.X_DIST * (MapGenerator.MAP_WIDTH - 1)
	var map_height_pixels := MapGenerator.Y_DIST * (MapGenerator.STEPS - 1)
	var viewport_width := get_viewport_rect().size.x
	var x_offset := (viewport_width - map_width_pixels) / 2

	steps.position = Vector2(x_offset, map_height_pixels + TOP_MARGIN)
	lines.position = Vector2(x_offset, map_height_pixels + TOP_MARGIN)

	for current_node: Array in map_data:
		for step: MapNode in current_node:
			if step.next_nodes.size() > 0:
				_spawn_node(step)

	var middle := floori(MapGenerator.MAP_WIDTH * 0.5)
	_spawn_node(map_data[MapGenerator.STEPS - 1][middle])

	visuals.custom_minimum_size = Vector2(map_width_pixels, map_height_pixels + BOTTOM_MARGIN + TOP_MARGIN)

	line_renderer.reveal_traveled_path(map_data)

	await get_tree().process_frame
	scroll_container.scroll_vertical = int(visuals.custom_minimum_size.y - scroll_container.size.y)

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
