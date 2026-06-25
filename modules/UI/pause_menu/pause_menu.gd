extends Control

func _ready() -> void:
	visible = false
	get_tree().paused = false
	%quit.pressed.connect(quit)

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().paused:
			visible = false
			get_tree().paused = false
		else:
			visible = true
			get_tree().paused = true

func quit() -> void:
	get_tree().paused = false
	scene_manager.goto_scene("res://modules/UI/start_menu/start_menu.tscn")
