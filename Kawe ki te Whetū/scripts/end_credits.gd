extends CanvasLayer

@export var credit_lines: Array[String] = [
	"Kawe ki te Whetū",
	"spacing",
	"Created by",
	"Your name here"
]
@export_range(1.0, 500.0, 1.0) var scroll_speed := 35.0
@export_range(1.0, 300.0, 1.0) var spacing_height := 36.0
@export_range(8, 96, 1) var font_size := 28
@export var control: Control

var credits_box: VBoxContainer


func _ready() -> void:
	if control == null:
		control = Control.new()
		control.name = "CreditsViewport"
		control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(control)

	control.clip_contents = true

	# Let the full-screen Control get its size before laying out the credits.
	await get_tree().process_frame

	_build_credits()
	credits_box.position = Vector2(0.0, control.size.y)


func _process(delta: float) -> void:
	if credits_box == null:
		return

	credits_box.position.y -= scroll_speed * delta


func _build_credits() -> void:
	credits_box = VBoxContainer.new()
	credits_box.size = Vector2(control.size.x, 0.0)
	credits_box.add_theme_constant_override("separation", 0)

	for line in credit_lines:
		if line.strip_edges().to_lower() == "spacing":
			var spacer := Control.new()
			spacer.custom_minimum_size.y = spacing_height
			credits_box.add_child(spacer)
			continue

		var credit_label := Label.new()
		credit_label.text = line
		credit_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		credit_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		credit_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		credit_label.add_theme_font_size_override("font_size", font_size)
		credits_box.add_child(credit_label)

	credits_box.custom_minimum_size.y = credits_box.get_combined_minimum_size().y
	control.add_child(credits_box)
