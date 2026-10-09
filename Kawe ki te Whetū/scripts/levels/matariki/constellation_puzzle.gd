extends Control

signal puzzle_completed

const STAR_NAMES: Array[StringName] = [
	&"Matariki",
	&"Pōhutukawa",
	&"Tupuānuku",
	&"Tupuārangi",
	&"Waipuna-ā-Rangi",
	&"Waitī",
	&"Waitā"
]

var placed_stars: Dictionary = {}
var selected_star: StringName = &""

@onready var status_label: Label = $Status
@onready var close_button: Button = $CloseButton
@onready var target_buttons: Array[Button] = [
	$Target1, $Target2, $Target3, $Target4, $Target5, $Target6, $Target7
]
@onready var inventory_buttons: Array[Button] = [
	$Star1Button, $Star2Button, $Star3Button, $Star4Button,
	$Star5Button, $Star6Button, $Star7Button
]

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	for index in STAR_NAMES.size():
		target_buttons[index].pressed.connect(_on_target_pressed.bind(index))
		target_buttons[index].connect("star_dropped", _on_star_dropped)
		inventory_buttons[index].pressed.connect(_on_star_pressed.bind(STAR_NAMES[index]))
	close_button.pressed.connect(queue_free)

func _on_star_pressed(star_id: StringName) -> void:
	var star_index := STAR_NAMES.find(star_id)
	if star_index < 0:
		return
	if placed_stars.values().has(star_id):
		status_label.text = "Star %d is already placed." % (star_index + 1)
		return
	selected_star = star_id
	status_label.text = "Selected Star %d. Choose its matching position." % (
		star_index + 1
	)

func _on_target_pressed(index: int) -> void:
	if selected_star.is_empty():
		status_label.text = "Choose a collected star first."
		return
	_place_star(index, selected_star)

func _on_star_dropped(target_index: int, star_index: int) -> void:
	if star_index < 0 or star_index >= STAR_NAMES.size():
		return
	_place_star(target_index, STAR_NAMES[star_index])

func _place_star(index: int, star_id: StringName) -> void:
	if index < 0 or index >= STAR_NAMES.size():
		return
	if placed_stars.has(index):
		status_label.text = "That position already has its star."
		return
	if star_id != STAR_NAMES[index]:
		status_label.text = "That is not the right place for the star."
		return

	var star_index := STAR_NAMES.find(star_id)
	if star_index < 0 or star_index >= inventory_buttons.size():
		status_label.text = "That star is not available."
		return

	placed_stars[index] = star_id
	target_buttons[index].text = "%s\n✦ Star %d" % [
		STAR_NAMES[index],
		star_index + 1
	]
	target_buttons[index].disabled = true
	inventory_buttons[star_index].disabled = true
	status_label.text = "Correct: Star %d" % (star_index + 1)
	selected_star = &""

	if placed_stars.size() == STAR_NAMES.size():
		status_label.text = "Matariki is complete! The stars are in their correct places."
		puzzle_completed.emit()
