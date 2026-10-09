extends CharacterBody3D

const GRAVITY := 40.0

@export_group("Player stats")
@export var move_speed := 10.0
@export var jump_velocity := 14.0


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
