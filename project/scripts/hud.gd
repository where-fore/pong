extends CanvasLayer

var max_bounces = 0
var bounces_this_set = 0
var has_played_more_than_one_set = false #don't want to pulse the score on first play

var score_should_pulse = false
var pulse_tween : Tween = null
var original_scale
var pulse_scale_factor = 1.75


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	HudEvents.ball_bounced.connect(_on_ball_bounced)
	
	#gonna do some scale changing later
	var label = $"Bounce Count Icon/Bounce Count Label"
	label.pivot_offset = label.get_size() / 2
	original_scale = label.scale


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if score_should_pulse and has_played_more_than_one_set:
		if not pulse_tween:
			start_pulse()
	elif not score_should_pulse:
		if pulse_tween:
			end_pulse()


func _on_right_wall_scored() -> void:
	update_scores($"Left Score Icon/Left Score Label")


func _on_left_wall_scored() -> void:
	update_scores($"Right Score Icon/Right Score Label")


func update_scores(label) -> void:
	label.show()
	label.text = str(int(label.text) + 1)
	bounces_this_set = 0
	score_should_pulse = false
	has_played_more_than_one_set = true
	

func _on_ball_bounced():
	bounces_this_set += 1
	if bounces_this_set > max_bounces:
		max_bounces = bounces_this_set
		score_should_pulse = true
	
	else:
		score_should_pulse = false
	
	$"Bounce Count Icon/Bounce Count Label".show()
	$"Bounce Count Icon/Bounce Count Label".text = str(max_bounces)
	

func start_pulse():
	var to_pulse = $"Bounce Count Icon/Bounce Count Label"
	pulse_tween = create_tween()
	pulse_tween.set_trans(Tween.TRANS_SINE)
	pulse_tween.set_ease(Tween.EASE_IN_OUT)
	pulse_tween.tween_property(to_pulse, "scale", original_scale*pulse_scale_factor, 0.5)
	pulse_tween.tween_property(to_pulse, "scale", original_scale, 0.5)
	pulse_tween.set_loops() #infinite
	
	
func end_pulse():
	var to_pulse = $"Bounce Count Icon/Bounce Count Label"
	pulse_tween.kill()
	pulse_tween = null
	to_pulse.scale = original_scale


func _on_start_button_vs_computer_pressed() -> void:
	pass # Replace with function body.


func _on_start_button_vs_local_pressed() -> void:
	pass # Replace with function body.
