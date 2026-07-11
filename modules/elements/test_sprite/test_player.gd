class_name test_player extends AnimatedSprite2D


@export var player_res : test_sprite

func _ready() -> void:
	%level_sample.text = "LEVEL: %s" % player_res.level
	Events.continue_pressed.connect(level_up)


# func _on_state_change_test_pressed() -> void:
# 	modulate = player_res.change_color()

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_left"):
		modulate = player_res.change_color()

func level_up() -> void:
	player_res.lvl_up()
	%level_sample.text = "LEVEL: %s" % player_res.level
