class_name test_sprite extends Resource

#this is a temporary file to test game state saving. DELETE THIS LATER along with other test nodes/scenes/scripts/etc.

@export var color : Color
@export var level : int

func lvl_up() -> int :
	level += 1
	return level

func change_color() -> Color:
	if color == Color.WHITE:
		color = Color.PINK
	else: 
		color = Color.WHITE
	return color