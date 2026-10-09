extends Node3D

const REQUIRED_STARS: Array[StringName] = [
	&"Matariki", &"Ururangi", &"Tupuānuku", &"Tupuārangi",
	&"Waipuna-ā-Rangi", &"Waitī", &"Waitā"
]
const STAR_FACT_DISPLAY_DURATION := 8.0
const STAR_FACT_FADE_IN_DURATION := 0.5
const STAR_FACT_FADE_OUT_DURATION := 1.0
const STAR_FACTS: Dictionary = {
	&"Matariki": (
		"Matariki means “little eyes”. As the mother star, it guides the cluster and is " +
		"linked to wellbeing and good fortune."
	),
	&"Ururangi": (
		"Ururangi means “winds of the sky” and is connected to the year's winds. " +
		"A bright, clear star is traditionally linked with calmer winds."
	),
	&"Tupuānuku": (
		"Tupuanuku means “to grow in the earth”. It is linked to foods grown in soil, " +
		"such as kūmara, and to a fruitful harvest."
	),
	&"Tupuārangi": (
		"Tupuarangi means “to grow in the sky”. It is linked to fruit, berries, " +
		"forest birds, and the health of the ngahere (forest)."
	),
	&"Waipuna-ā-Rangi": (
		"Waipuna-a-Rangi is connected to rain that nourishes life. A bright, " +
		"clear star is traditionally linked with lighter rain."
	),
	&"Waitī": (
		"Waiti means “sweet water” and watches over freshwater and its food, like tuna " +
		"(eels), inanga (whitebait), and kōura (crayfish)."
	),
	&"Waitā": (
		"Waita means “salt water” and is connected to the ocean, tides, and marine life. " +
		"It also honours waters navigated by ancestral waka."
	)
}

@export var puzzle_scene : PackedScene
@export var door: Node3D
@export var star1: Area3D
@export var star2: Area3D
@export var star3: Area3D
@export var star4: Area3D
@export var star5: Area3D
@export var star6: Area3D
@export var star7: Area3D

@export var star_pickup : AudioStream
@export var open_telecsope : AudioStream

var collected_stars: Array[StringName] = []
var player_near_center := false
var puzzle_open := false
var mission_completed := false
var paused_game_scene: Node
var saved_game_scene_process_mode := Node.PROCESS_MODE_INHERIT
var guidance_visible_before_puzzle := true
var star_fact_visible_before_puzzle := false
var previous_camera: Camera3D
var center_area: Area3D
var guidance_label: Label
var star_fact_label: Label
var star_fact_timer: Timer
var star_fact_tween: Tween


func _ready() -> void:
	for star in [star1, star2, star3, star4, star5, star6, star7]:
		if star != null:
			star.collected.connect(_on_star_collected)
	_setup_star_status_hud()
	_setup_center_node()


func _unhandled_input(event: InputEvent) -> void:
	if player_near_center and not puzzle_open and event.is_action_pressed("interact"):
		if collected_stars.size() != REQUIRED_STARS.size():
			return
		
		_open_puzzle()
		get_viewport().set_input_as_handled()


func _on_star_collected(star_id: StringName) -> void:
	if not collected_stars.has(star_id):
		collected_stars.append(star_id)
		_show_star_fact(star_id)
		_update_star_guidance()
	
	HelperFunctions.spawn_temp_sound(star_pickup)


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

	star_fact_label = Label.new()
	star_fact_label.name = "CollectedStarFact"
	star_fact_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	star_fact_label.offset_left = 48.0
	star_fact_label.offset_top = -150.0
	star_fact_label.offset_right = -48.0
	star_fact_label.offset_bottom = -30.0
	star_fact_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	star_fact_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	star_fact_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	star_fact_label.add_theme_font_size_override("font_size", 21)
	star_fact_label.add_theme_font_override(
		"font",
		load("res://other_assets/fonts/Boring Time.otf") as Font
	)
	star_fact_label.add_theme_color_override("font_color", Color(0.95, 0.95, 1.0))
	star_fact_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.95))
	star_fact_label.add_theme_constant_override("outline_size", 5)
	star_fact_label.visible = false
	canvas.add_child(star_fact_label)

	star_fact_timer = Timer.new()
	star_fact_timer.one_shot = true
	star_fact_timer.timeout.connect(_fade_out_star_fact)
	canvas.add_child(star_fact_timer)
	_update_star_guidance()


func _show_star_fact(star_id: StringName) -> void:
	if star_fact_label == null:
		return
	star_fact_timer.stop()
	if star_fact_tween != null and star_fact_tween.is_running():
		star_fact_tween.kill()
	var fact: String = STAR_FACTS.get(star_id, "Learn more about the stars of Matariki.")
	star_fact_label.text = "%s\n%s" % [_display_star_name(star_id), fact]
	star_fact_label.visible = true
	star_fact_label.modulate.a = 0.0
	star_fact_tween = create_tween()
	star_fact_tween.tween_property(
		star_fact_label,
		"modulate:a",
		1.0,
		STAR_FACT_FADE_IN_DURATION
	)
	star_fact_tween.finished.connect(_on_star_fact_faded_in)


func _display_star_name(star_id: StringName) -> String:
	var display_name := str(star_id)
	display_name = display_name.replace("ā", "a").replace("Ā", "A")
	display_name = display_name.replace("ī", "i").replace("Ī", "I")
	return display_name


func _on_star_fact_faded_in() -> void:
	if star_fact_label != null and star_fact_label.visible:
		star_fact_timer.start(STAR_FACT_DISPLAY_DURATION)


func _fade_out_star_fact() -> void:
	if star_fact_label == null or not star_fact_label.visible:
		return
	star_fact_tween = create_tween()
	star_fact_tween.tween_property(
		star_fact_label,
		"modulate:a",
		0.0,
		STAR_FACT_FADE_OUT_DURATION
	)
	star_fact_tween.finished.connect(_hide_star_fact)


func _hide_star_fact() -> void:
	if star_fact_label != null:
		star_fact_label.visible = false
	star_fact_tween = null


func _update_star_guidance() -> void:
	if guidance_label == null:
		return
	if mission_completed:
		guidance_label.text = "Matariki complete!"
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
	add_child(center_area)
	var telescope := get_node_or_null("StoneTelescope") as Node3D
	if telescope != null:
		center_area.global_position = telescope.global_position + Vector3.UP * 0.8
	else:
		push_warning("StoneTelescope was not found; using the fallback interaction position.")
		center_area.position = Vector3(11.2, 0.8, 0.0)
	center_area.body_entered.connect(_on_center_body_entered)
	center_area.body_exited.connect(_on_center_body_exited)

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
	
	HelperFunctions.spawn_temp_sound(open_telecsope)
	var game_scene := get_tree().current_scene
	if puzzle_scene == null or game_scene == null:
		push_error("The constellation puzzle or current game scene is missing.")
		return
	var puzzle := puzzle_scene.instantiate()
	puzzle_open = true
	
	paused_game_scene = game_scene
	saved_game_scene_process_mode = game_scene.process_mode
	game_scene.process_mode = Node.PROCESS_MODE_DISABLED
	guidance_visible_before_puzzle = guidance_label.visible
	star_fact_visible_before_puzzle = star_fact_label.visible
	guidance_label.hide()
	star_fact_label.hide()
	previous_camera = get_viewport().get_camera_3d()
	var puzzle_camera := get_node_or_null("Camera3D") as Camera3D
	if puzzle_camera != null:
		puzzle_camera.make_current()
	else:
		push_warning("Puzzle Camera3D was not found; keeping the current camera.")
	Global.mouse_captured = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	puzzle.connect("puzzle_completed", _on_puzzle_completed)
	puzzle.tree_exited.connect(_on_puzzle_closed)
	puzzle.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(puzzle)


func _on_puzzle_completed() -> void:
	mission_completed = true
	_update_star_guidance()
	door.open_door()


func _on_puzzle_closed() -> void:
	if is_instance_valid(paused_game_scene):
		paused_game_scene.process_mode = saved_game_scene_process_mode
	paused_game_scene = null
	if is_instance_valid(previous_camera):
		previous_camera.make_current()
	previous_camera = null
	guidance_label.visible = guidance_visible_before_puzzle
	star_fact_label.visible = star_fact_visible_before_puzzle
	Global.mouse_captured = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	puzzle_open = false
