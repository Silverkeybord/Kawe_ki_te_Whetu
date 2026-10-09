class_name Door
extends Node3D

@export var scene: PackedScene
@export var portal: MeshInstance3D
@export var area: Area3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_meta(Player.PLAYER_META):
		get_tree().call_deferred("change_scene_to_packed",scene)


func open_door() -> void:
	portal.visible = true
	area.monitoring = true
