class_name MapNodeButton extends TextureButton

const ICONS := {
	MapNode.Type.NOT_ASSIGNED: [null, Vector2(3.0, 3.0)],
	MapNode.Type.FISHING: [preload("res://assets/public/map_node_fishing.png"), Vector2(3.0, 3.0)],
	MapNode.Type.SHOP: [preload("res://assets/public/map_node_shop.png"), Vector2(5.0, 5.0)],
	MapNode.Type.EVENT: [preload("res://assets/public/map_node_event.png"), Vector2(3.0, 3.0)],
	MapNode.Type.BOSS: [preload("res://assets/public/map_node_boss.png"), Vector2(6.0, 6.0)],
}

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var select_sprite: Sprite2D = $Sprite2D

var available := false: set = set_available
var step: MapNode: set = set_node
var can_dismiss := false

var pulse_animator: PulseAnimator

func _ready() -> void:
	Events.can_dismiss_changed.connect(_on_dismiss_changed)
	Events.line_animation_finished.connect(_on_line_animation_finished)

func _on_dismiss_changed(value: bool) -> void:
	can_dismiss = value
	_update_highlight()

func set_available(new_value: bool) -> void:
	available = new_value
	_update_highlight()

func _update_highlight() -> void:
	if available and not can_dismiss:
		pulse_animator.play()
	else:
		pulse_animator.stop()

func set_node(new_data: MapNode) -> void:
	step = new_data
	texture_normal = ICONS[step.type][0]
	scale = ICONS[step.type][1]
	pivot_offset = size / 2
	position = step.position - pivot_offset
	pulse_animator = PulseAnimator.new(self, ICONS[step.type][1])

func _on_map_node_selected() -> void:
	Events.selected.emit(step)

func _on_line_animation_finished(finished_step: MapNode) -> void:
	if finished_step == step:
		select_sprite.rotation = randf_range(0.0, TAU)
		animation_player.play("select")

func _on_pressed() -> void:
	if not available:
		return
	step.selected = true
	Events.path_chosen.emit(step)
	pulse_animator.stop()