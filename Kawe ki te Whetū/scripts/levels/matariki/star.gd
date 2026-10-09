extends Area3D

signal collected(star_id: StringName)

@export var star_id: StringName

@export_group("Bobbing Settings")
@export var bob_height : float = 12.0       # Distance (pixels or units) to float up and down
@export var cycle_duration : float = 2.0    # Duration in seconds for a full up-and-down loop
@export var random_offset : bool = true     # Offsets start time so multiple stars don't move in sync
@export var trans_type : Tween.TransitionType = Tween.TRANS_SINE
@export var ease_type : Tween.EaseType = Tween.EASE_IN_OUT

var has_been_collected := false

func _ready() -> void:
	if star_id.is_empty():
		star_id = StringName(name)
	body_entered.connect(_on_body_entered)
	
	if random_offset:
		# Random initial delay so stars float out of sync
		await get_tree().create_timer(randf_range(0.0, cycle_duration)).timeout
	
		start_bobbing()


func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and not has_been_collected:
		has_been_collected = true
		collected.emit(star_id)
		queue_free()


func start_bobbing() -> void:
	var start_y := position.y
	var half_cycle := cycle_duration / 2.0

	var tween := create_tween().set_loops()
	
	# Float UP from starting position
	tween.tween_property(self, "position:y", start_y - bob_height, half_cycle)\
		.set_trans(trans_type)\
		.set_ease(ease_type)
		
	# Float DOWN back to starting position
	tween.tween_property(self, "position:y", start_y, half_cycle)\
		.set_trans(trans_type)\
		.set_ease(ease_type)
