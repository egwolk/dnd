class_name fishing_view_state extends LimboState

@onready var fishing_ui = $fishing_view
@onready var map_state = %map_view_state
var pause_capture: PauseCapture

func _setup() -> void:
	fishing_ui.visible = false
	pause_capture = PauseCapture.new(self, map_state)

func _enter() -> void:
	fishing_ui.visible = true

func _exit() -> void:
	fishing_ui.visible = false

func _unhandled_input(event: InputEvent) -> void:
	pause_capture.handle_input(event)

func _on_lose_test_pressed() -> void:
	pause_capture.frozen_bg()
	dispatch(&"LOSE_SELECTED")

func _on_win_test_pressed() -> void:
	pause_capture.frozen_bg()
	dispatch(&"WIN_SELECTED")