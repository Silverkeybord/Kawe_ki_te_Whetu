extends Control

signal puzzle_completed

const STAR_COUNT := 7
const STAR_NAMES := [
	"Matariki",
	"Ururangi",
	"Tupuanuku",
	"Tupuarangi",
	"Waipuna-a-Rangi",
	"Waiti",
	"Waita"
]

var placed_stars: Dictionary = {}
var selected_star_index := -1

@onready var status_label: Label = $Status
@onready var close_button: Button = $CloseButton
@onready var star_labels: Array[Label] = [
	$StarTray/MatarikiName,
	$StarTray/UrurangiName,
	$StarTray/TupuanukuName,
	$StarTray/TupuarangiName,
	$StarTray/WaipunarangiName,
	$StarTray/WaitiName,
	$StarTray/WaitaName
]
@onready var target_buttons: Array[Button] = [
	$CenterBox/TargetMatariki,
	$CenterBox/TargetUrurangi,
	$CenterBox/TargetTupuanuku,
	$CenterBox/TargetTupuarangi,
	$CenterBox/TargetWaipunarangi,
	$CenterBox/TargetWaiti,
	$CenterBox/TargetWaita
]
@onready var target_labels: Array[Label] = [
	$CenterBox/PlacedNameMatariki,
	$CenterBox/PlacedNameUrurangi,
	$CenterBox/PlacedNameTupuanuku,
	$CenterBox/PlacedNameTupuarangi,
	$CenterBox/PlacedNameWaipunarangi,
	$CenterBox/PlacedNameWaiti,
	$CenterBox/PlacedNameWaita
]
@onready var star_buttons: Array[Button] = [
	$StarTray/Matariki,
	$StarTray/Ururangi,
	$StarTray/Tupuanuku,
	$StarTray/Tupuarangi,
	$StarTray/Waipunarangi,
	$StarTray/Waiti,
	$StarTray/Waita
]


func _ready() -> void:
	for index in STAR_COUNT:
		target_buttons[index].pressed.connect(_on_target_pressed.bind(index))
		target_buttons[index].connect("star_dropped", _on_star_dropped)
		star_buttons[index].pressed.connect(_on_star_pressed.bind(index))
	close_button.pressed.connect(queue_free)


func _on_star_pressed(star_index: int) -> void:
	if placed_stars.values().has(star_index):
		status_label.text = "That star has already been placed."
		return
	selected_star_index = star_index
	status_label.text = "Selected star. Choose its circle."


func _on_target_pressed(target_index: int) -> void:
	if placed_stars.has(target_index):
		status_label.text = "That circle already has a star."
		return
	if selected_star_index < 0:
		status_label.text = "Choose a star first."
		return
	_place_star(target_index, selected_star_index)


func _on_star_dropped(target_index: int, star_index: int) -> void:
	_place_star(target_index, star_index)


func _place_star(target_index: int, star_index: int) -> void:
	if target_index < 0 or target_index >= STAR_COUNT:
		return
	if star_index < 0 or star_index >= STAR_COUNT:
		return
	if placed_stars.has(target_index):
		status_label.text = "That circle already has a star."
		return
	if target_index != star_index:
		status_label.text = "That is not the right place for the star."
		return

	placed_stars[target_index] = star_index
	target_buttons[target_index].icon = star_buttons[star_index].icon
	var empty_style := StyleBoxEmpty.new()
	for style_name in [&"normal", &"hover", &"pressed", &"disabled", &"focus"]:
		target_buttons[target_index].add_theme_stylebox_override(style_name, empty_style)
	target_labels[target_index].text = STAR_NAMES[star_index]
	target_labels[target_index].show()
	star_buttons[star_index].call("mark_placed")
	star_labels[star_index].hide()
	status_label.text = "Correct!"
	selected_star_index = -1

	if placed_stars.size() == STAR_COUNT:
		status_label.text = "Matariki is complete!"
		puzzle_completed.emit()
		queue_free()
