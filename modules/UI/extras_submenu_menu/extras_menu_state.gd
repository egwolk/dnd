class_name extras_menu_state extends LimboState

@onready var extras_ui = $extras_screen

func _setup() -> void:
	extras_ui.visible = false

func _enter() -> void:
	extras_ui.visible = true
	WaterOverlayManager.show_in(extras_ui)

func _exit() -> void:
	extras_ui.visible = false
	WaterOverlayManager.hide_overlay()
