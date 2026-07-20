class_name Map extends Control

const SCROLL_SPEED := 15

const MAP_NODE = preload("res://modules/elements/map/map_node_button.tscn")
const MAP_LINE = preload("res://modules/elements/map/map_line.tscn")

@onready var map_generator: MapGenerator = %map_generator
@onready var lines: Control = %map_lines
@onready var steps: Control = %map_nodes
@onready var visuals: Control = $PanelContainer/MarginContainer/ScrollContainer/map_visuals
@onready var scroll_container: ScrollContainer = $PanelContainer/MarginContainer/ScrollContainer

var map_data: Array[Array]
var steps_taken: int
var last_node: MapNode
var camera_edge_y: float
var line_map: Dictionary

const SELECTED_LINE_COLOR := Color("red")
const LINE_SHADER := preload("res://modules/elements/map/map_line_animation.gdshader")

const BOTTOM_MARGIN := 200
const TOP_MARGIN := MapGenerator.Y_DIST + 200

func _ready() -> void:
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

	_color_traveled_path()

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
	_connect_lines(step)

func _connect_lines(step: MapNode) -> void:
	if step.next_nodes.is_empty():
		return

	for next: MapNode in step.next_nodes:
		var new_map_line := MAP_LINE.instantiate() as Line2D
		new_map_line.add_point(step.position)
		new_map_line.add_point(next.position)

		var mat := ShaderMaterial.new()
		mat.shader = LINE_SHADER
		mat.set_shader_parameter("line_start", step.position)
		mat.set_shader_parameter("line_end", next.position)
		mat.set_shader_parameter("reveal_color", SELECTED_LINE_COLOR)
		new_map_line.material = mat

		lines.add_child(new_map_line)
		line_map[_line_key(step, next)] = new_map_line

func _line_key(from_node: MapNode, to_node: MapNode) -> String:
	return "%s->%s" % [from_node.get_instance_id(), to_node.get_instance_id()]

func _animate_line(from_node: MapNode, to_node: MapNode) -> void:
	var key := _line_key(from_node, to_node)
	if not line_map.has(key):
		Events.line_animation_finished.emit(to_node)
		return

	var mat := (line_map[key] as Line2D).material as ShaderMaterial
	if mat == null:
		Events.line_animation_finished.emit(to_node)
		return

	var tween := create_tween()
	tween.tween_method(
		func(value: float) -> void: mat.set_shader_parameter("progress", value),
		0.0, 1.0, 0.4
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.finished.connect(func() -> void: Events.line_animation_finished.emit(to_node))

func _color_traveled_path() -> void:
	for current_step: Array in map_data:
		for step: MapNode in current_step:
			if not step.selected:
				continue
			for next: MapNode in step.next_nodes:
				if next.selected:
					var mat := (line_map[_line_key(step, next)] as Line2D).material as ShaderMaterial
					if mat:
						mat.set_shader_parameter("progress", 1.0)

func _on_map_node_path_chosen(step: MapNode) -> void:
	if last_node:
		_animate_line(last_node, step)
	else:
		Events.line_animation_finished.emit(step)

func _on_map_node_selected(step: MapNode) -> void:
	for map_node: MapNodeButton in steps.get_children():
		if map_node.step.row == step.row:
			map_node.available = false

	last_node = step
	steps_taken += 1
	unlock_next_nodes()
