class_name map_view_state extends LimboState

@onready var map_ui = $map_screen

var can_dismiss: bool = false  

func _setup() -> void:
    map_ui.visible = false

func _enter() -> void:
    map_ui.visible = true
    get_tree().paused = true

func _exit() -> void:
    map_ui.visible = false

func _unhandled_input(_event: InputEvent) -> void:
    if Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("m_pressed"):
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
