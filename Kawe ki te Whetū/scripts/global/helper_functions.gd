class_name HelperFunctions
extends Node

const TEMP_SOUND_SCENE_3D := preload("res://scenes/sound/temp_sound_scene_3D.tscn")
const TEMP_SOUND_SCENE := preload("res://scenes/sound/temp_sound_scene.tscn")
const ROOT_NODES_GROUP: String = "root_nodes"


## of root nodes in the current scene
static func add_to_root_node(node: Node) -> bool:
	if node == null:
		return false
	
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	
	var root_node := tree.get_first_node_in_group(ROOT_NODES_GROUP)
	if root_node == null:
		return false

	root_node.add_child(node)
	return true


## Sets the mouse of the player to be unlocked or locked bassed on its last value
static func set_mouse_captured(set_mode: bool = false, set_value: bool = false) -> void:
	if set_mode:
		Global.mouse_captured = set_value
	else:
		Global.mouse_captured = not Global.mouse_captured
	
	if Global.mouse_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


## spawns a sound at a position or a flat sound bassed on a position pramater
static func spawn_temp_sound(sound: AudioStream, pos: Vector3 = Vector3.ZERO) -> void:
	if sound == null:
		return

	if pos != Vector3.ZERO:
		var new_sound: AudioStreamPlayer3D = TEMP_SOUND_SCENE_3D.instantiate()
		new_sound.stream = sound
		if not add_to_root_node(new_sound):
			new_sound.queue_free()
			return

		new_sound.global_position = pos
		new_sound.volume_db = sound.volume
		new_sound.max_db = sound.max_db
		new_sound.max_distance = sound.max_distance
		new_sound.play()
	else:
		var new_sound: AudioStreamPlayer = TEMP_SOUND_SCENE.instantiate()
		new_sound.stream = sound
		if not add_to_root_node(new_sound):
			new_sound.queue_free()
			return
		
		new_sound.play()
