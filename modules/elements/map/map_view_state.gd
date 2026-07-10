class_name map_view_state extends LimboState

@onready var map_ui = $map_screen

var can_dismiss: bool = false:
    set(value):
        can_dismiss = value
        _set_buttons_disabled(value)

func _setup() -> void:
    map_ui.visible = false

func _enter() -> void:
    map_ui.visible = true
    get_tree().paused = true

func _exit() -> void:
    map_ui.visible = false

func _set_buttons_disabled(value: bool) -> void:
    for button in get_tree().get_nodes_in_group("map_buttons"):
        button.disabled = value

func _unhandled_input(_event: InputEvent) -> void:
    if Input.is_action_just_pressed("ui_cancel"):
        if can_dismiss:
            get_tree().paused = false
            Events.pause_background_cleared.emit()
            dispatch(&"UNPAUSE")
        else:
            dispatch(&"PAUSE")
    elif Input.is_action_just_pressed("m_pressed"):
        if can_dismiss:
            get_tree().paused = false
            Events.pause_background_cleared.emit()
            dispatch(&"UNPAUSE")
        else:
            return

func _on_button_pressed() -> void:
    can_dismiss = true
    get_tree().paused = false
    Events.pause_background_cleared.emit()
    dispatch( &"LEVEL_SELECTED" )
