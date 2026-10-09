class_name HelperFunctions
extends Node


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
