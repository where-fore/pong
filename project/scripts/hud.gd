extends CanvasLayer

var max_bounces = 0
var bounces_this_set = 0
var has_played_more_than_one_set = false #don't want to pulse the score on first play

var score_should_pulse = false
var pulse_tween : Tween = null
var pulse_scale_factor = 1.25


@onready var bounce_count_label = $"Bounce Count Icon/Bounce Count Label"
@onready var original_font_size = bounce_count_label.get_theme_font_size("font_size", bounce_count_label.get_class())


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	HudEvents.ball_bounced.connect(_on_ball_bounced)
	
	#gonna do some scale changing later
	bounce_count_label.pivot_offset = bounce_count_label.get_size() / 2


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
	
	bounce_count_label.show()
	bounce_count_label.text = str(max_bounces)
	

func start_pulse():
	pulse_tween = create_tween()
	pulse_tween.set_trans(Tween.TRANS_SINE)
	pulse_tween.set_ease(Tween.EASE_IN_OUT)
	pulse_tween.tween_method(_apply_font_size_tween, original_font_size, original_font_size*pulse_scale_factor, 0.5)
	pulse_tween.tween_method(_apply_font_size_tween, original_font_size*pulse_scale_factor, original_font_size,  0.5)
	pulse_tween.set_loops() #infinite


func _apply_font_size_tween(size_to_scale):
	bounce_count_label.add_theme_font_size_override("font_size", size_to_scale)


func end_pulse():
	pulse_tween.kill()
	pulse_tween = null
	bounce_count_label.add_theme_font_size_override("font_size", original_font_size)


func _on_start_button_vs_computer_pressed() -> void:
	pass # Replace with function body.


func _on_start_button_vs_local_pressed() -> void:
	pass # Replace with function body.
