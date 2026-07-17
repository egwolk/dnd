class_name MapNodeButton extends TextureButton

const ICONS := {
	MapNode.Type.NOT_ASSIGNED: [null, Vector2(3.0, 3.0)],
	MapNode.Type.FISHING: [preload("res://assets/public/map_node_fishing.png"), Vector2(3.0, 3.0)],
	MapNode.Type.SHOP: [preload("res://assets/public/map_node_shop.png"), Vector2(3.0, 3.0)],
	MapNode.Type.EVENT: [preload("res://assets/public/map_node_event.png"), Vector2(3.0, 3.0)],
	MapNode.Type.BOSS: [preload("res://assets/public/map_node_boss.png"), Vector2(6.0, 6.0)],
}

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var available := false: set = set_available
var step: MapNode: set = set_node

func _apply_available_visual(force_restart: bool = false, skip_animation: bool = false) -> void:
	if step.selected:
		return

	if force_restart:
		animation_player.stop()

	if available and not skip_animation:
		animation_player.play("highlight")
	elif not available:
		animation_player.play("RESET")

func set_available(new_value: bool) -> void:
	available = new_value
	_apply_available_visual()

func refresh_highlight(skip_animation: bool = false) -> void:
	_apply_available_visual(true, skip_animation)

func set_node(new_data: MapNode) -> void:
	step = new_data
	texture_normal = ICONS[step.type][0]
	scale = ICONS[step.type][1]
	pivot_offset = size / 2
	position = step.position - pivot_offset

func _on_map_node_selected() -> void:
	Events.selected.emit(step)

func _on_pressed() -> void:
	if not available:
		return
	step.selected = true
	animation_player.play("select")
