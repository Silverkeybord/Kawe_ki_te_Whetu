extends Button

signal star_dropped(target_index: int, star_index: int)

@export_range(0, 6) var target_index := 0

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if not data is Dictionary or not data.has("star_index"):
		return false
	var star_index: int = data["star_index"]
	return star_index >= 1 and star_index <= 7

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	star_dropped.emit(target_index, data["star_index"] - 1)
