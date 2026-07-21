class_name MapGenerator extends Node

const X_DIST := 150
const Y_DIST := 200
const PLACEMENT_RANDOMNESS := 25
const STEPS := 10
const MAP_WIDTH := 7
const PATHS := 6
const FISHING_NODE_WEIGHT := 10.0
const EVENT_NODE_WEIGHT := 4.0
const SHOP_NODE_WEIGHT := 2.5

var random_node_type_weights = {
	MapNode.Type.FISHING : 0.0,
	MapNode.Type.EVENT : 0.0,
	MapNode.Type.SHOP : 0.0,
}

var random_node_type_total_weight := 0
var map_data: Array[Array]

func generate_map() -> Array[Array]:
	map_data = _generate_initial_grid()
	var starting_points := _get_random_starting_points()

	for j in starting_points:
		var current_j := j
		for i in STEPS - 1:
			current_j = _setup_connection(i, current_j)

	_setup_boss_node()
	_setup_random_node_weights()
	_setup_node_types()

	return map_data


func _generate_initial_grid() -> Array[Array]:
	var result : Array[Array] = []

	for i in STEPS:
		var adjacent_nodes : Array[MapNode] = []

		for j in MAP_WIDTH:
			var current_node := MapNode.new()
			var placement_randomness := 0 if i == STEPS - 1 else PLACEMENT_RANDOMNESS
			var offset := Vector2(randf(), randf()) * placement_randomness

			current_node.position = Vector2(j * X_DIST, i * -Y_DIST) + offset
			current_node.row = i
			current_node.column = j
			current_node.next_nodes = []

			if  i == STEPS -1:
				current_node.position.y = (i + 1) * -Y_DIST

			adjacent_nodes.append(current_node)

		result.append(adjacent_nodes)

	return result

func _get_random_starting_points() -> Array[int]:
	var y_coordinates: Array[int]
	var unique_points: int = 0

	while unique_points < 2:
		unique_points = 0
		y_coordinates = []

		for i in PATHS:
			var starting_point := randi_range(0, MAP_WIDTH - 1)
			if not y_coordinates.has(starting_point):
				unique_points += 1
			y_coordinates.append(starting_point)
	return y_coordinates

func _setup_connection(i: int, j: int) -> int:
	var next_node: MapNode
	var current_node := map_data[i][j] as MapNode

	while not next_node or _would_cross_existing_path(i, j, next_node):
		var random_j := clampi(randi_range(j - 1, j + 1), 0, MAP_WIDTH - 1)
		next_node = map_data[i + 1][random_j]
	current_node.next_nodes.append(next_node)
	return next_node.column

func _would_cross_existing_path(i: int, j: int, step: MapNode) -> bool:
	var left_neighbor: MapNode
	var right_neighbor: MapNode

	if j > 0:
		left_neighbor = map_data[i][j - 1]
	if j < MAP_WIDTH - 1:
		right_neighbor = map_data[i][j + 1]

	if right_neighbor and step.column > j:
		for next_node: MapNode in right_neighbor. next_nodes:
			if next_node.column < step.column:
				return true
	if left_neighbor and step.column < j:
		for next_node: MapNode in left_neighbor.next_nodes:
			if next_node.column > step.column:
				return true
	return false

func _setup_boss_node() -> void:
	var middle := floori(MAP_WIDTH * 0.5)
	var boss_node := map_data[STEPS - 1][middle] as MapNode

	for j in MAP_WIDTH:
		var current_node = map_data[STEPS - 2][j] as MapNode
		if current_node.next_nodes:
			current_node.next_nodes = [] as Array[MapNode]
			current_node.next_nodes.append(boss_node)

	boss_node.type = MapNode.Type.BOSS

func _setup_random_node_weights() -> void:
	random_node_type_weights[MapNode.Type.FISHING] = FISHING_NODE_WEIGHT
	random_node_type_weights[MapNode.Type.EVENT] = FISHING_NODE_WEIGHT + EVENT_NODE_WEIGHT
	random_node_type_weights[MapNode.Type.SHOP] = FISHING_NODE_WEIGHT + EVENT_NODE_WEIGHT + SHOP_NODE_WEIGHT

	random_node_type_total_weight = random_node_type_weights[MapNode.Type.SHOP]

func _setup_node_types() -> void:
	for step: MapNode in map_data[0]:
		if step.next_nodes.size() > 0:
			step.type = MapNode.Type.FISHING

	for step: MapNode in map_data[STEPS - 2]:
		if step.next_nodes.size() > 0:
			step.type = MapNode.Type.SHOP

	for current_step in map_data:
		for step: MapNode in current_step:
			for next_node: MapNode in step.next_nodes:
				if next_node.type == MapNode.Type.NOT_ASSIGNED:
					_set_node_randomly(next_node)

func _set_node_randomly(node_to_set: MapNode) -> void:
	var consecutive_event := true
	var consecutive_shop := true
	var shop_on_row_before_second_last := true

	var type_candidate: MapNode.Type

	while consecutive_event or consecutive_shop or shop_on_row_before_second_last:
		type_candidate = _get_random_node_type_by_weight()

		var is_event := type_candidate == MapNode.Type.EVENT
		var has_event_parent := _node_has_parent_of_type(node_to_set, MapNode.Type.EVENT)
		var is_shop := type_candidate == MapNode.Type.SHOP
		var has_shop_parent := _node_has_parent_of_type(node_to_set, MapNode.Type.SHOP)

		consecutive_event = is_event and has_event_parent
		consecutive_shop = is_shop and has_shop_parent
		shop_on_row_before_second_last = is_shop and node_to_set.row == STEPS - 3
	node_to_set.type = type_candidate

func _node_has_parent_of_type(step: MapNode, type: MapNode.Type) -> bool:
	var parents: Array[MapNode] = []

	if step.column > 0 and step.row > 0:
		var parent_candidate := map_data[step.row - 1][step.column -1] as MapNode
		if parent_candidate.next_nodes.has(step):
			parents.append(parent_candidate)

	if step.row > 0:
		var parent_candidate := map_data[step.row - 1][step.column] as MapNode
		if parent_candidate.next_nodes.has(step):
			parents.append(parent_candidate)

	if step.column < MAP_WIDTH - 1 and step.row > 0:
		var parent_candidate := map_data[step.row - 1][step.column + 1] as MapNode
		if parent_candidate.next_nodes.has(step):
			parents.append(parent_candidate)

	for parent: MapNode in parents:
		if parent.type == type:
			return true

	return false

func _get_random_node_type_by_weight() -> MapNode.Type:
	var roll := randf_range(0.0, random_node_type_total_weight)

	for type: MapNode.Type in random_node_type_weights:
		if random_node_type_weights[type] > roll:
			return type

	return MapNode.Type.FISHING
