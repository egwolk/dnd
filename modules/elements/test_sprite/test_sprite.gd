extends AnimatedSprite2D

#this is a temporary file to test game state saving. DELETE THIS LATER along with other test nodes/scenes/scripts/etc.

func _on_state_change_test_pressed() -> void:
	if modulate == Color.WHITE:
		modulate = Color.PINK
	else:
		modulate = Color.WHITE
