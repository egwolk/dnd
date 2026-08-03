class_name loadingScreen extends Control

var _target_path: String
var _loading: bool = false

func begin_load(path: String) -> void:
	_target_path = path
	var err = ResourceLoader.load_threaded_request(path)
	if err != OK:
		push_error("loading_screen: failed to request load for %s (error %s)" % [path, err])
		return
	_loading = true
	set_process(true)

func _process(_delta: float) -> void:
	if not _loading:
		return

	var status = ResourceLoader.load_threaded_get_status(_target_path)

	match status:
		ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			push_error("loading_screen: failed to load %s" % _target_path)
			_loading = false
			set_process(false)
		ResourceLoader.THREAD_LOAD_LOADED:
			_loading = false
			set_process(false)
			_finish_load()

func _finish_load() -> void:
	await get_tree().process_frame

	var warmer := ShaderWarmer.new()
	add_child(warmer)
	await warmer.warm_up([
		preload("res://modules/UI/common_shaders/water_caustic.gdshader"),
		preload("res://modules/UI/common_shaders/top_blur.gdshader"),
		preload("res://modules/UI/common_shaders/bubbles_far.gdshader"),
		preload("res://modules/UI/common_shaders/color_filter_blue.gdshader"),
		preload("res://modules/elements/map/map_node_outline.gdshader"),
		preload("res://modules/elements/map/map_select_animation.gdshader"),
		preload("res://modules/elements/map/map_line_animation.gdshader"),
	])
	warmer.queue_free()

	var packed_scene: PackedScene = ResourceLoader.load_threaded_get(_target_path)
	var new_scene = packed_scene.instantiate()

	var container = get_parent()
	container.add_child(new_scene)
	SceneManager.current_scene_instance = new_scene

	queue_free()