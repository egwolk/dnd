class_name MapLineRenderer extends RefCounted

const MAP_LINE = preload("res://modules/elements/map/map_line.tscn")
const LINE_SHADER := preload("res://modules/elements/map/map_line_animation.gdshader")
const SELECTED_LINE_COLOR := Color("red")
const ANIMATION_DURATION := 0.4

var _container: Control
var _line_map: Dictionary

func _init(container: Control) -> void:
	_container = container

func connect_nodes(step: MapNode) -> void:
	if step.next_nodes.is_empty():
		return

	for next: MapNode in step.next_nodes:
		var new_line := MAP_LINE.instantiate() as Line2D
		new_line.add_point(step.position)
		new_line.add_point(next.position)

		var mat := ShaderMaterial.new()
		mat.shader = LINE_SHADER
		mat.set_shader_parameter("line_start", step.position)
		mat.set_shader_parameter("line_end", next.position)
		mat.set_shader_parameter("reveal_color", SELECTED_LINE_COLOR)
		new_line.material = mat

		_container.add_child(new_line)
		_line_map[_key(step, next)] = new_line

func animate(from_node: MapNode, to_node: MapNode) -> void:
	var mat := _material_for(from_node, to_node)
	if mat == null:
		Events.line_animation_finished.emit(to_node)
		return

	var tween := _container.create_tween()
	tween.tween_method(
		func(value: float) -> void: mat.set_shader_parameter("progress", value),
		0.0, 1.0, ANIMATION_DURATION
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.finished.connect(func() -> void: Events.line_animation_finished.emit(to_node))

func reveal_traveled_path(map_data: Array[Array]) -> void:
	for current_step: Array in map_data:
		for step: MapNode in current_step:
			if not step.selected:
				continue
			for next: MapNode in step.next_nodes:
				if next.selected:
					var mat := _material_for(step, next)
					if mat:
						mat.set_shader_parameter("progress", 1.0)

func _material_for(from_node: MapNode, to_node: MapNode) -> ShaderMaterial:
	var key := _key(from_node, to_node)
	if not _line_map.has(key):
		return null
	return (_line_map[key] as Line2D).material as ShaderMaterial

func _key(from_node: MapNode, to_node: MapNode) -> String:
	return "%s->%s" % [from_node.get_instance_id(), to_node.get_instance_id()]