class_name win_view_state 
extends LimboState

@onready var win_ui = $win_screen
@onready var continue_button = %continue
@onready var map_state = %map_view_state
@onready var run_controller = %run_view_controller

func _setup() -> void:
	win_ui.visible = false

func _enter() -> void:
	win_ui.visible = true
	get_tree().paused = true
	WaterOverlayManager.show_in(win_ui)

	var prev_state = run_controller.get_previous_active_state()
	continue_button.visible = (prev_state != run_controller.boss_state)

func _exit() -> void:
	win_ui.visible = false
	WaterOverlayManager.hide_overlay()

func _on_quit_pressed() -> void:
	get_tree().paused = false
	Events.pause_background_cleared.emit()
	SceneManager.goto_scene("res://modules/UI/start_menu/start_menu.tscn")


func _on_continue_pressed() -> void:
	get_tree().paused = false
	Events.pause_background_cleared.emit()
	map_state.can_dismiss = false
	dispatch(&"MAP_SELECTED")
