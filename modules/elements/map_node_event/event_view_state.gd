class_name event_view_state extends LimboState

@onready var event_ui = $event_view
@onready var map_state = %map_view_state
var pause_capture: PauseCapture

func _setup() -> void:
	event_ui.visible = false
	pause_capture = PauseCapture.new(self, map_state)

func _enter() -> void:
	event_ui.visible = true

func _exit() -> void:
	event_ui.visible = false

func _unhandled_input(event: InputEvent) -> void:
	pause_capture.handle_input(event)

func _on_next_node_pressed() -> void:
	map_state.can_dismiss = false
	dispatch(&"MAP_SELECTED")