class_name config_menu_state extends LimboState

@onready var extras_ui = $config_screen

func _setup() -> void:
    extras_ui.visible = false

func _enter() -> void:
    extras_ui.visible = true

func _exit() -> void:
    extras_ui.visible = false
