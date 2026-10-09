class_name Door
extends Node3D

@export var open_sound : AudioStream
@export var enter_sound : AudioStream

@export var scene: PackedScene
@export var portal: MeshInstance3D
@export var area: Area3D
@export var white_out_rect : ColorRect


func _ready() -> void:
	_fade_tween(false)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_meta(Player.PLAYER_META):
		_fade_tween()
		HelperFunctions.spawn_temp_sound(enter_sound, global_position)
		get_tree().call_deferred("change_scene_to_packed",scene)


func open_door() -> void:
	portal.visible = true
	area.monitoring = true
	HelperFunctions.spawn_temp_sound(open_sound)


func _fade_tween(fade_out : bool = true) -> void:
	var fade_tween := create_tween()
	var target_mod := white_out_rect.color
	if fade_out:
		target_mod.a = 1
	else:
		target_mod.a = 0 
		
	fade_tween.tween_property(
		white_out_rect, "modulate", target_mod, 1.5).set_ease(Tween.EASE_IN)
	await fade_tween.finished
