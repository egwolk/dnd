class_name ShaderWarmer extends Node

func warm_up(shaders: Array[Shader]) -> void:
	for shader in shaders:
		await _warm_one(shader)


func _warm_one(shader: Shader) -> void:
	var mat := ShaderMaterial.new()
	mat.shader = shader

	var viewport := SubViewport.new()
	viewport.size = Vector2i(4, 4)  
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE

	var rect := ColorRect.new()
	rect.size = Vector2(4, 4)
	rect.material = mat

	viewport.add_child(rect)
	add_child(viewport)

	await get_tree().process_frame
	await get_tree().process_frame

	viewport.queue_free()