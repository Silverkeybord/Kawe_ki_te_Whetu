extends Node3D

enum MoonPhases {
	NEW_MOON,
	WAXING_CRESCENT,
	FIRST_QUARTER,
	WAXING_GIBBOUS,
	FULL_MOON,
	WANING_GIBBOUS,
	LAST_QUARTER,
	WANING_CRESCENT
}

const INTERACTION_RANGE := 5
const QUESTION_FORMAT := "Q : %s"
const QA_KEY := {
	1 : {
		"question" : "Which Moon phase is almost invisible from Earth and marks the beginning of many maramataka lunar months?",
		"ans" : MoonPhases.NEW_MOON
	},
	2 : {
		"question" : "Which Moon phase occurs when the Moon's sunlit side faces mostly away from Earth?",
		"ans" : MoonPhases.NEW_MOON
	},
	3 : {
		"question" : "Which phase appears as a thin, growing sliver of light after the New Moon?",
		"ans" : MoonPhases.WAXING_CRESCENT
	},
	4 : {
		"question" : "Which Moon phase is beginning to brighten as the lunar month progresses?",
		"ans" : MoonPhases.WAXING_CRESCENT
	},
	5 : {
		"question" : "Which phase shows approximately half of the Moon illuminated as it grows brighter?",
		"ans" : MoonPhases.FIRST_QUARTER
	},
	6 : {
		"question" : "Which phase comes after the Waxing Crescent and before the Waxing Gibbous?",
		"ans" : MoonPhases.FIRST_QUARTER
	},
	7 : {
		"question" : "Which phase has more than half of its visible surface illuminated and is still growing?",
		"ans" : MoonPhases.WAXING_GIBBOUS
	},
	8 : {
		"question" : "Which phase appears just before the Full Moon as the bright area continues to increase?",
		"ans" : MoonPhases.WAXING_GIBBOUS
	},
	9 : {
		"question" : "Which phase shows the Moon's Earth-facing side almost completely illuminated?",
		"ans" : MoonPhases.FULL_MOON
	},
	10 : {
		"question" : "Which phase is associated with Rakaunui, a traditional Maori name for the Full Moon?",
		"ans" : MoonPhases.FULL_MOON
	},
	11 : {
		"question" : "Which phase has more than half of its visible surface illuminated, but is beginning to shrink?",
		"ans" : MoonPhases.WANING_GIBBOUS
	},
	12 : {
		"question" : "Which phase follows the Full Moon as the illuminated area starts decreasing?",
		"ans" : MoonPhases.WANING_GIBBOUS
	},
	13 : {
		"question" : "Which phase shows approximately half of the Moon illuminated as it gets darker?",
		"ans" : MoonPhases.LAST_QUARTER
	},
	14 : {
		"question" : "Which phase occurs between the Waning Gibbous and Waning Crescent?",
		"ans" : MoonPhases.LAST_QUARTER
	},
	15 : {
		"question" : "Which phase appears as a thin, shrinking crescent before the next New Moon?",
		"ans" : MoonPhases.WANING_CRESCENT
	},
	16 : {
		"question" : "Which phase comes just before the Moon becomes almost invisible again?",
		"ans" : MoonPhases.WANING_CRESCENT
	}
}
const ROTATION_FACTOR := PI/4
const ROTATE_TIME := 0.5

const GO_TO_TABLET := "go to moon stone"
const GO_TO_DOOR := "go to the portal"
const QUESTIONS_FORMAT := "%s/8 Questions"
const INTERACT_TEXT := "E to interact"

@export var moon_stone : Node3D
@export var player : CharacterBody3D
@export var puzzle_canvas_layer : CanvasLayer
@export var rich_text_label : RichTextLabel
@export var phase_spinner : TextureRect
@export var door : Door
@export var indicator_text : Label
@export var puzzle_root : Control

@export var moon_phase_open_sound : AudioStream

var question_index := 0
var questions : Array
var selected_moon_phase := MoonPhases.NEW_MOON
var rotate_tween : Tween
var in_range := false
var show_tweening := false


func _ready() -> void:
	questions = generate_random_question_order()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		if in_range:
			open_puzzle()
	
	# Process input controls ownly while the puzzle UI is active
	if puzzle_canvas_layer.visible:
		if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("ui_left"):
			_rotate(1)
		if Input.is_action_just_pressed("right") or Input.is_action_just_pressed("ui_right"):
			_rotate(-1)
		
		if Input.is_action_just_pressed("enter") or Input.is_action_just_pressed("jump"):
			_on_button_pressed()
	
	if question_index == 8:
		indicator_text.text = GO_TO_DOOR
	elif in_range:
		indicator_text.text = INTERACT_TEXT
	elif not in_range and question_index != 7:
		indicator_text.text = GO_TO_TABLET
	elif puzzle_canvas_layer.visible == true: 
		indicator_text.text = QUESTIONS_FORMAT % str(question_index)


func generate_random_question_order() -> Array:
	# Starting index for each of the 8 unique moon phase question pairs
	var phase_starts := [1, 3, 5, 7, 9, 11, 13, 15]
	phase_starts.shuffle() # Shuffle to pick 4 random distinct phases
	
	var order := []
	for i in range(4):
		# Pick either question option 1 or option 2 for each chosen phase
		order.append(phase_starts[i] + (randi() % 2))
		
	order.shuffle() # Shuffle the final 4 questions
	return order


func open_puzzle() -> void:
	if show_tweening:
		return
	
	show_tweening = true
	Global.moon_puzzle_active = true
	HelperFunctions.set_mouse_captured(true, false)
	puzzle_canvas_layer.visible = true
	rich_text_label.text = QUESTION_FORMAT % QA_KEY[questions[question_index]]["question"]
	
	HelperFunctions.spawn_temp_sound(moon_phase_open_sound)
	
	var show_tween := create_tween()
	show_tween.tween_property(puzzle_root, "position", Vector2(0, 0), 0.5)
	show_tween.set_trans(Tween.TRANS_EXPO)
	await show_tween.finished


func ask_next_question() -> void:
	question_index += 1
	if question_index < questions.size():
		rich_text_label.text = QUESTION_FORMAT % QA_KEY[questions[question_index]]["question"]
	else:
		HelperFunctions.set_mouse_captured(true, true)
		Global.moon_puzzle_active = false
		puzzle_canvas_layer.visible = false
		door.open_door()


func _on_button_pressed() -> void:
	if QA_KEY[questions[question_index]]["ans"] == selected_moon_phase:
		ask_next_question()


func _rotate(dir : int) -> void:
	# Prevent starting a new rotation while one is already playing
	if rotate_tween and rotate_tween.is_running():
		return
	
	# Keep rotation anchored in the middle of the texture
	phase_spinner.pivot_offset = phase_spinner.size / 2.0
	
	var target_rotate := phase_spinner.rotation + (dir * ROTATION_FACTOR)
	
	rotate_tween = create_tween()
	rotate_tween.tween_property(phase_spinner, "rotation", target_rotate, ROTATE_TIME)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_CUBIC)
	
	
	var total_phases := MoonPhases.size()
	selected_moon_phase = posmod(selected_moon_phase + dir, total_phases) as MoonPhases


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_meta(Player.PLAYER_META):
		in_range = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.has_meta(Player.PLAYER_META):
		in_range = false
