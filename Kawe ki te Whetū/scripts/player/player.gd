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


## Handles gravity, movement input, and jumping every physics frame.
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0
	
	var input_dir := Input.get_vector(
		"left",
		"right",
		"forward",
		"back"
	)
	
	var direction := (
		global_basis * Vector3(input_dir.x, 0.0, input_dir.y)
	).normalized()
	
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	move_and_slide()


func _toggle_player_visible(toggle: bool) -> void:
	if not toggle:
		await get_tree().create_timer(HIDE_WAIT_TIME).timeout
	
	player_mesh.visible = toggle
	particles.visible = toggle
