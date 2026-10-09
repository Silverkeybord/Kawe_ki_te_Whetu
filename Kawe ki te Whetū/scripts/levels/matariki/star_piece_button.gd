extends Button

@export_range(1, 7) var star_index := 1

func _get_drag_data(_at_position: Vector2) -> Variant:
	var preview := Label.new()
	preview.text = "Star %d" % star_index
	preview.add_theme_font_size_override("font_size", 18)
	set_drag_preview(preview)
	return {"star_index": star_index}
