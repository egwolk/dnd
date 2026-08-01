extends Node

## Autoload singleton — register this as "WaterOverlayManager" in
## Project Settings > Autoload, the same way Events / SceneManager
## are registered.
##
## Owns exactly ONE instance of water_bg_overlay.tscn for the whole
## game. Screens (pause, map, win, lose, extras) call show_in() when
## they want the water background and hide() when they're done,
## instead of each embedding their own copy in the scene tree.
## This means only one set of SubViewports and one SCREEN_TEXTURE
## read ever exists at a time, instead of one per screen.

const WATER_OVERLAY_SCENE := preload("res://modules/UI/common_shaders/water_bg_overlay.tscn")

var _overlay: Control


func _ready() -> void:
	_overlay = WATER_OVERLAY_SCENE.instantiate()
	_overlay.visible = false
	# Park it under the autoload itself until a screen claims it.
	# process_mode ALWAYS so it can still be requested/rendered while
	# get_tree().paused is true (e.g. from the pause menu).
	process_mode = Node.PROCESS_MODE_ALWAYS
	_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_overlay)


## Call from a screen's _enter()/_setup() to pull the shared overlay
## into that screen, as its first child (so it renders behind
## everything else added after it).
func show_in(target: Control) -> void:
	if _overlay.get_parent() != target:
		_overlay.reparent(target, false)
		target.move_child(_overlay, 0)
		_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.visible = true


## Call from that screen's _exit() when it no longer needs the
## overlay. Doesn't reparent it away immediately — just hides it, so
## the SubViewports stop refreshing (your throttle script already
## skips work while !visible) until the next screen claims it.
func hide_overlay() -> void:
	_overlay.visible = false