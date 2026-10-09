extends Button

@export_range(1, 7) var star_index := 1

var drag_in_progress := false
var is_placed := false

func _get_drag_data(_at_position: Vector2) -> Variant:
	drag_in_progress = true
	hide()
	var preview := Control.new()
	var star_image := TextureRect.new()
	star_image.texture = icon
	star_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	star_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	star_image.size = Vector2(84.0, 84.0)
	star_image.position = -star_image.size * 0.5
	star_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview.add_child(star_image)
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_drag_preview(preview)
	return {"star_index": star_index}

func _notification(what: int) -> void:
	if what != NOTIFICATION_DRAG_END or not drag_in_progress:
		return

	drag_in_progress = false
	if not is_drag_successful() and not is_placed:
		show()

func mark_placed() -> void:
	is_placed = true
	drag_in_progress = false
	hide()
