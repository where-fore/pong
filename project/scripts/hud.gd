extends CanvasLayer

signal start_game
var max_bounces = 0
var bounces_this_set = 0
var has_played_more_than_one_set = false #don't want to pulse the score on first play

var score_should_pulse = false
var pulse_tween : Tween = null
var original_scale
var pulse_scale_factor = 1.75


var startup_timer = 10 #countdown to start the game

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


func _on_start_button_pressed() -> void:
	$"Start Button".hide()
	$"Start Countdown".show()
	$"Start Countdown/Start Countdown Timer".start(startup_timer)
	await get_tree().create_timer(startup_timer).timeout #nothing to wait for
	emit_signal("start_game")


func _on_start_countdown_timer_timeout() -> void:
	$"Start Countdown".hide()


func _on_right_wall_scored() -> void:
	$"Keys Score Icon/Keys Score Label".show()
	$"Keys Score Icon/Keys Score Label".text = str(int($"Keys Score Icon/Keys Score Label".text) + 1)
	bounces_this_set = 0
	score_should_pulse = false
	has_played_more_than_one_set = true


func _on_left_wall_scored() -> void:
	$"Cursor Score Icon/Cursor Score Label".show()
	$"Cursor Score Icon/Cursor Score Label".text = str(int($"Cursor Score Icon/Cursor Score Label".text) + 1)
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
	pulse_tween = create_tween()
	pulse_tween.set_trans(Tween.TRANS_SINE)
	pulse_tween.set_ease(Tween.EASE_IN_OUT)
	pulse_tween.tween_property($"Bounce Count Icon/Bounce Count Label", "scale", original_scale*pulse_scale_factor, 0.5)
	pulse_tween.tween_property($"Bounce Count Icon/Bounce Count Label", "scale", original_scale, 0.5)
	pulse_tween.set_loops() #infinite
	
	
func end_pulse():
	pulse_tween.kill()
	pulse_tween = null
	$"Bounce Count Icon/Bounce Count Label".scale = original_scale
