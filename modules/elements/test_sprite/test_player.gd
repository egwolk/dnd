class_name test_player extends AnimatedSprite2D


@export var player_res : test_sprite

func _ready() -> void:
	%level_sample.text = "LEVEL: %s" % player_res.level


func _on_state_change_test_pressed() -> void:
	modulate = player_res.change_color()


func _on_win_test_pressed() -> void:
	player_res.lvl_up()
	%level_sample.text = "LEVEL: %s" % player_res.level
