extends Node3D

const REQUIRED_STARS: Array[StringName] = [
	&"Matariki", &"Ururangi", &"Tupuānuku", &"Tupuārangi",
	&"Waipuna-ā-Rangi", &"Waitī", &"Waitā"
]

@export var puzzle_scene : PackedScene
@export var door: Node3D
@export var star1: Area3D
@export var star2: Area3D
@export var star3: Area3D
@export var star4: Area3D
@export var star5: Area3D
@export var star6: Area3D
@export var star7: Area3D

var collected_stars: Array[StringName] = []
var player_near_center := false
var puzzle_open := false
var center_area: Area3D
var guidance_label: Label


func _ready() -> void:
	for star in [star1, star2, star3, star4, star5, star6, star7]:
		if star != null:
			star.collected.connect(_on_star_collected)
	_setup_star_status_hud()
	_setup_center_node()


func _unhandled_input(event: InputEvent) -> void:
	if player_near_center and not puzzle_open and event.is_action_pressed("interact"):
		if collected_stars.size() != REQUIRED_STARS.size():
			print("Collect all seven stars before using the telescope.")
			return
		_open_puzzle()
		get_viewport().set_input_as_handled()


func _on_star_collected(star_id: StringName) -> void:
	if not collected_stars.has(star_id):
		collected_stars.append(star_id)
		_update_star_guidance()
	print("Collected star: ", star_id)


func _setup_star_status_hud() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "StarStatusHUD"
	add_child(canvas)

	guidance_label = Label.new()
	guidance_label.name = "PlayerGuidance"
	guidance_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	guidance_label.offset_top = 18.0
	guidance_label.offset_bottom = 54.0
	guidance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	guidance_label.add_theme_font_size_override("font_size", 24)
	guidance_label.add_theme_font_override(
		"font",
		load("res://other_assets/fonts/Boring Time.otf") as Font
	)
	guidance_label.add_theme_color_override("font_color", Color(0.95, 0.95, 1.0))
	canvas.add_child(guidance_label)
	_update_star_guidance()


func _update_star_guidance() -> void:
	if guidance_label == null:
		return
	var all_stars_collected := collected_stars.size() == REQUIRED_STARS.size()
	if all_stars_collected and player_near_center:
		guidance_label.text = "Press E to use the telescope"
	elif all_stars_collected:
		guidance_label.text = "All 7 stars collected! Go to the telescope"
	else:
		guidance_label.text = "%d/7 stars" % collected_stars.size()


func _setup_center_node() -> void:
	center_area = Area3D.new()
	center_area.name = "TelescopeInteraction"
	var telescope := get_node_or_null("StoneTelescope") as Node3D
	if telescope != null:
		center_area.global_position = telescope.global_position + Vector3.UP * 0.8
	else:
		push_warning("StoneTelescope was not found; using the fallback interaction position.")
		center_area.position = Vector3(11.2, 0.8, 0.0)
	center_area.body_entered.connect(_on_center_body_entered)
	center_area.body_exited.connect(_on_center_body_exited)
	add_child(center_area)

	var collision := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 1.4
	collision.shape = sphere
	center_area.add_child(collision)


func _on_center_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		player_near_center = true
		_update_star_guidance()


func _on_center_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		player_near_center = false
		_update_star_guidance()


func _open_puzzle() -> void:
	if puzzle_open:
		return
	puzzle_open = true
	Global.mouse_captured = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var puzzle := puzzle_scene.instantiate()
	puzzle.connect("puzzle_completed", _on_puzzle_completed)
	puzzle.tree_exited.connect(_on_puzzle_closed)
	puzzle.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(puzzle)
	get_tree().paused = true


func _on_puzzle_completed() -> void:
	guidance_label.text = "Matariki complete!"
	door.open_door()


func _on_puzzle_closed() -> void:
	get_tree().paused = false
	Global.mouse_captured = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	puzzle_open = false
