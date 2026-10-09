extends Node3D

@export var xy_camera_marker: Marker3D
@export var z_camera_marker: Marker3D
@export var lerp_power: float = 1.0


func _process(delta: float) -> void:
	if xy_camera_marker == null or z_camera_marker == null:
		return
	
	var lerp_weight := clampf(delta * lerp_power, 0.0, 1.0)
	position = lerp(
		position,
		Vector3(
			z_camera_marker.position.z,
			0,
			xy_camera_marker.position.z
		),
		lerp_weight
	)
