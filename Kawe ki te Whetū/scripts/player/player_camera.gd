extends Node3D
# Controls the player's camera rotation and zoom distance.

# =============================================================================
# CONSTANTS
# =============================================================================

const BASE_SENSITIVITY: float = 0.003

# Input actions
const ACTION_TOGGLE_MOUSE_CAPTURE: StringName = &"toggle_mouse_capture"

# Camera bounds & offsets
const MIN_PITCH: float = -PI / 2
const MAX_PITCH: float = PI / 4

const ZOOM_SPEED: float = 0.5
const MAX_ZOOM: float = 10.0
const FIRST_PERSON_THRESHOLD: float = 0.75
const FIRST_PERSON_CAMERA_LENGTH: float = 0.0
const THIRD_PERSON_CAMERA_OFFSET: Vector3 = Vector3(0, 1.4, 0)
const FIRST_PERSON_CAMERA_OFFSET: Vector3 = Vector3(0.0, 1, 0.0)
const THIRD_PERSON_Z_SPRING_LENGTH: float = 0.5

# =============================================================================
# EXPORTS
# =============================================================================
@export_group("Scene References")
@export var player: Player
@export var xy_spring_arm: SpringArm3D
@export var z_spring_arm: SpringArm3D

var pitch: float = 0.0
var zoom_value: float = 3.0


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# takes all inputs and turns them into camera movement
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Global.mouse_captured:
		_pan_and_pitch(event as InputEventMouseMotion)
	
	if event is InputEventMouseButton:
		_zoom_in_out(event)


# Camera movement
# controls camera movement
func _pan_and_pitch(event: InputEventMouseMotion) -> void:
	if player == null:
		return
	
	player.rotation.y -= event.relative.x * Global.sensitivity * BASE_SENSITIVITY
	
	pitch -= event.relative.y * Global.sensitivity * BASE_SENSITIVITY
	pitch = clampf(pitch, MIN_PITCH, MAX_PITCH)
	
	rotation.x = pitch


# controls zooming in and out
func _zoom_in_out(event: InputEventMouseButton) -> void:
	if xy_spring_arm == null or z_spring_arm == null:
		return
	
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		zoom_value -= ZOOM_SPEED
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		zoom_value += ZOOM_SPEED
	
	zoom_value = clampf(zoom_value, FIRST_PERSON_THRESHOLD, MAX_ZOOM)
	xy_spring_arm.spring_length = zoom_value
	
	# zooming to a threshold snaps the camera to a first-person perspective
	if zoom_value <= FIRST_PERSON_THRESHOLD:
		player._toggle_player_visible(false)
		position = FIRST_PERSON_CAMERA_OFFSET
		xy_spring_arm.spring_length = FIRST_PERSON_CAMERA_LENGTH
		z_spring_arm.spring_length = FIRST_PERSON_CAMERA_LENGTH
	else:
		player._toggle_player_visible(true)
		position = THIRD_PERSON_CAMERA_OFFSET
		z_spring_arm.spring_length = THIRD_PERSON_Z_SPRING_LENGTH
