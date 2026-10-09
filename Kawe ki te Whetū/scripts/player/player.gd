class_name Player
extends CharacterBody3D

const PLAYER_META := "player"
const GRAVITY := 40.0
const HIDE_WAIT_TIME := 0.35
const INTERACT_DISTANCE := 5.0

@export_group("Player stats")
@export var move_speed := 12.0
@export var jump_velocity := 16.0

@export_group("In scene")
@export var player_mesh : MeshInstance3D
@export var particles : GPUParticles3D
@export var camera_controller : Node3D


## Handles gravity, movement input, and jumping every physics frame.
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0
	
	if not Global.moon_puzzle_active:
		var input_dir := Input.get_vector("left", "right", "back", "forward")
		
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
		
		if camera_controller:
			# Calculate movement direction relative to camera facing direction
			var cam_basis := camera_controller.global_transform.basis
			var forward := -cam_basis.z
			forward.y = 0.0
			forward = forward.normalized()
			
			var right := cam_basis.x
			right.y = 0.0
			right = right.normalized()
			
			var direction := (right * input_dir.x + forward * input_dir.y).normalized()
			
			velocity.x = direction.x * move_speed
			velocity.z = direction.z * move_speed
			
			# Rotate mesh toward movement direction
			if direction != Vector3.ZERO and player_mesh:
				var target_angle := atan2(-direction.x, -direction.z)
				player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, target_angle, 12.0 * delta)
	
	move_and_slide()


func _toggle_player_visible(toggle: bool) -> void:
	if not toggle:
		await get_tree().create_timer(HIDE_WAIT_TIME).timeout
	
	player_mesh.visible = toggle
	particles.visible = toggle
