class_name shop_view_state extends LimboState

@onready var shop_ui = $shop_view
@onready var map_state = %map_view_state
var pause_capture: PauseCapture

func _setup() -> void:
	shop_ui.visible = false
	pause_capture = PauseCapture.new(self, map_state)

func _enter() -> void:
	shop_ui.visible = true

func _exit() -> void:
	shop_ui.visible = false

func _unhandled_input(event: InputEvent) -> void:
	pause_capture.handle_input(event)

func _on_next_node_pressed() -> void:
	map_state.can_dismiss = false
	dispatch(&"MAP_SELECTED")