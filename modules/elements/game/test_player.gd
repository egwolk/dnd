class_name test_player extends AnimatedSprite2D


@export var player_res : test_sprite

func _on_state_change_test_pressed() -> void:
    modulate = player_res.change_color()
