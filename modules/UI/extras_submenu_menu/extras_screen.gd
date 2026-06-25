extends Control


func _ready() -> void:
    pass

func _unhandled_input(event: InputEvent) -> void:
    if not visible: return

    if event.is_action_pressed("ui_cancel"):
        visible = false
        get_viewport().set_input_as_handled()