extends Node3D

const REQUIRED_STARS: Array[StringName] = [
	&"Matariki", &"Pōhutukawa", &"Tupuānuku", &"Tupuārangi",
	&"Waipuna-ā-Rangi", &"Waitī", &"Waitā"
]

@export var puzzle_scene : PackedScene

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
var center_label: Label3D


func _ready() -> void:
	for star in [star1, star2, star3, star4, star5, star6, star7]:
		if star != null:
			star.collected.connect(_on_star_collected)
	_setup_center_node()


func _unhandled_input(event: InputEvent) -> void:
	if player_near_center and not puzzle_open and event.is_action_pressed("interact"):
		if collected_stars.size() != REQUIRED_STARS.size():
			print("Collect all seven stars before using the constellation stone.")
			return
		_open_puzzle()
		get_viewport().set_input_as_handled()


func _on_star_collected(star_id: StringName) -> void:
	if not collected_stars.has(star_id):
		collected_stars.append(star_id)
	print("Collected star: ", star_id)
	_update_center_label()


func _setup_center_node() -> void:
	center_area = Area3D.new()
	center_area.name = "ConstellationStone"
	center_area.position = Vector3(11.2, 0.8, 0.0)
	center_area.body_entered.connect(_on_center_body_entered)
	center_area.body_exited.connect(_on_center_body_exited)
	add_child(center_area)

	var collision := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 1.4
	collision.shape = sphere
	center_area.add_child(collision)

	var mesh_instance := MeshInstance3D.new()
	var sphere_mesh := SphereMesh.new()
	sphere_mesh.radius = 0.65
	sphere_mesh.height = 1.3
	mesh_instance.mesh = sphere_mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.25, 0.65, 0.95)
	material.emission_enabled = true
	material.emission = Color(0.1, 0.45, 1.0)
	mesh_instance.material_override = material
	center_area.add_child(mesh_instance)

	center_label = Label3D.new()
	center_label.position = Vector3(0.0, 1.1, 0.0)
	center_area.add_child(center_label)
	_update_center_label()


func _update_center_label() -> void:
	if center_label == null:
		return
	if collected_stars.size() == REQUIRED_STARS.size():
		center_label.text = "Press E: place the stars"
	else:
		center_label.text = "%d / 7 stars" % collected_stars.size()


func _on_center_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		player_near_center = true


func _on_center_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		player_near_center = false


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
	center_label.text = "Matariki complete!"


func _on_puzzle_closed() -> void:
	get_tree().paused = false
	Global.mouse_captured = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	puzzle_open = false
