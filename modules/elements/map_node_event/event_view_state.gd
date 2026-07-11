class_name event_view_state extends LimboState

@onready var event_ui = $event_view
@onready var map_state = %map_view_state

func _setup() -> void:
    event_ui.visible = false

func _enter() -> void:
   event_ui.visible = true

func _exit() -> void:
    event_ui.visible = false

func  _unhandled_input(_event: InputEvent) -> void:
    if Input.is_action_just_pressed("ui_cancel"):
        frozen_bg()
        dispatch( &"PAUSE" )
    if Input.is_action_just_pressed("m_pressed"):
        frozen_bg()
        map_state.can_dismiss = true
        dispatch(&"MAP_SELECTED")

func _on_next_node_pressed() -> void:
    map_state.can_dismiss = false
    Events.continue_pressed.emit()
    dispatch(&"MAP_SELECTED")

func frozen_bg() -> void:
    var img = get_viewport().get_texture().get_image()
    var tex = ImageTexture.create_from_image(img)
    Events.pause_background_captured.emit(tex)
