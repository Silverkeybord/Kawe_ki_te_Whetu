extends Area3D

signal collected(star_id: StringName)

@export var star_id: StringName
var has_been_collected := false

func _ready() -> void:
	if star_id.is_empty():
		star_id = StringName(name)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and not has_been_collected:
		has_been_collected = true
		collected.emit(star_id)
		queue_free()
