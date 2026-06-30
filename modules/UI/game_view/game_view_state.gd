class_name game_view_state extends LimboState

@onready var game_view = $game_scene

func _setup() -> void:
	game_view.visible = false

func _enter() -> void:
	game_view.visible = true

func _exit() -> void:
	game_view.visible = false

func  _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		var img = get_viewport().get_texture().get_image()
		var tex = ImageTexture.create_from_image(img)
		Events.pause_background_captured.emit(tex)
		dispatch( &"PAUSE_GAME" )
