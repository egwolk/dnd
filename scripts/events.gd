extends Node

signal pause_background_captured(texture: ImageTexture)
signal pause_background_cleared
signal map_node_pressed
signal selected(step: MapNode)
signal path_chosen(step: MapNode)
signal can_dismiss_changed(value: bool)