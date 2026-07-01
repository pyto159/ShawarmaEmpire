extends Node


func change_scene(scene_path: String) -> void:
	var error: Error = get_tree().change_scene_to_file(scene_path)
	if error != OK:
		push_error("Unable to change scene to %s" % scene_path)
