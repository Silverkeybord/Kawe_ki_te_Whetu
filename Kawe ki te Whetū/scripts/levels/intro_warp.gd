extends CanvasLayer

const TEXT_TWEEN_TIME := 0.8

@export var label : Label
@export var warp_rect : ColorRect 
@export var white_out_rect := ColorRect
@export var next_scene : PackedScene
@export var portal_change_sound : AudioStream

var intro_message := [
	{
		"duration" : 1.5,
		"message" : "You are being taken away"
	},
	{
		"duration" : 1.25,
		"message" : "To an alternate place"
	},
	{
		"duration" : 1.25,
		"message" : "To find where"
	},
	{
		"duration" : 1.5,
		"message" : "You belong in the stars"
	},
]


func _ready() -> void:
	if label:
		play_intro_sequence()


func play_intro_sequence() -> void:
	# Initialize the first message
	label.text = intro_message[0]["message"].strip_edges()
	label.pivot_offset = label.size / 2.0
	label.scale = Vector2(1.0, 1.0)
	label.modulate.a = 1.0
	
	for i in range(intro_message.size()):
		var current_data = intro_message[i]
		
		# 1. Hold current text for its duration
		await get_tree().create_timer(current_data["duration"]).timeout
		
		# If there's a next message, transition into it
		if i < intro_message.size() - 1:
			var next_data = intro_message[i + 1]
			
			# 2. Fade Out (Alpha 1 -> 0) & Scale Up (1 -> 4)
			label.pivot_offset = label.size / 2.0
			var tween_out := create_tween().set_parallel(true)
			tween_out.tween_property(label, "scale", Vector2(4.0, 4.0), TEXT_TWEEN_TIME).set_ease(Tween.EASE_IN)
			tween_out.tween_property(label, "modulate:a", 0.0, TEXT_TWEEN_TIME).set_ease(Tween.EASE_IN)
			await tween_out.finished
			
			# 3. Change text and set up initial Fade In values
			label.text = next_data["message"].strip_edges()
			label.scale = Vector2(0.25, 0.25)
			label.modulate.a = 0.0
			label.pivot_offset = label.size / 2.0
			
			# 4. Fade In (Alpha 0 -> 1) & Scale Up (0.25 -> 1)
			var tween_in := create_tween().set_parallel(true)
			tween_in.tween_property(label, "scale", Vector2(1.0, 1.0), TEXT_TWEEN_TIME).set_ease(Tween.EASE_IN)
			tween_in.tween_property(label, "modulate:a", 1.0, TEXT_TWEEN_TIME).set_ease(Tween.EASE_IN)
			await tween_in.finished

	# Fade out the final message at the end of the sequence
	label.pivot_offset = label.size / 2.0
	var final_fade := create_tween().set_parallel(true)
	final_fade.tween_property(label, "scale", Vector2(4.0, 4.0), TEXT_TWEEN_TIME).set_ease(Tween.EASE_IN)
	final_fade.tween_property(label, "modulate:a", 0.0, TEXT_TWEEN_TIME).set_ease(Tween.EASE_IN)
	
	# Start warping shader properties simultaneously with the final text fade
	if warp_rect and warp_rect.material is ShaderMaterial:
		var mat = warp_rect.material as ShaderMaterial
		var start_warp := create_tween().set_parallel(true)
		start_warp.tween_property(mat, "shader_parameter/warp_speed", 15.0, 2).set_ease(Tween.EASE_IN)
		start_warp.tween_property(mat, "shader_parameter/spin_speed", 0.75, 2).set_ease(Tween.EASE_IN)
		start_warp.tween_property(mat, "shader_parameter/streak_density", 150.0, 2).set_ease(Tween.EASE_IN)
		start_warp.tween_property(mat, "shader_parameter/blur_amount", 0.8, 2).set_ease(Tween.EASE_IN)
	
	HelperFunctions.spawn_temp_sound(portal_change_sound)
	
	var fade_to_white_tween := create_tween().set_parallel(true)
	fade_to_white_tween.tween_property(white_out_rect, "modulate", Color("ffffffff"), 2).set_ease(Tween.EASE_IN)
	await fade_to_white_tween.finished
	
	get_tree().change_scene_to_packed(next_scene)
