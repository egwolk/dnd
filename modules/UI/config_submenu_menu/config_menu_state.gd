class_name config_menu_state extends LimboState

@onready var config_ui = $config_screen

func _setup() -> void:
    config_ui.visible = false

func _enter() -> void:
    config_ui.visible = true
    WaterOverlayManager.show_in(config_ui)

func _exit() -> void:
    config_ui.visible = false
    WaterOverlayManager.hide_overlay()
