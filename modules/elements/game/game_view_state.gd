class_name game_view_state extends LimboState

@onready var game_view = $game_scene
@onready var video_player :VideoStreamPlayer =  $game_scene/game     # temporary for testing. will remove later

func _setup() -> void:
	game_view.visible = false
	Events.quit_to_main_requested.connect(_on_quit_to_main_requested)

func _enter() -> void:
	game_view.visible = true
	# temporary for testing. will remove later
	if not video_player.is_playing():
		video_player.play()
	video_player.paused = false

func _exit() -> void:
	game_view.visible = false
	 # temporary for testing. will remove later
	video_player.paused = true

func _on_quit_to_main_requested() -> void:
	video_player.stop()

func  _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		var img = get_viewport().get_texture().get_image()
		var tex = ImageTexture.create_from_image(img)
		Events.pause_background_captured.emit(tex)
		dispatch( &"PAUSE_GAME" )
