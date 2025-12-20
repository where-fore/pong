extends Area2D

var paddle_speed_factor = 500
@onready var screen_height = get_viewport_rect().size.y
@onready var screen_middle = screen_height/2
@onready var paddle_height = $CollisionShape2D.shape.get_rect().size.y
@onready var min_screen_can_travel = paddle_height/2
@onready var max_screen_can_travel = (screen_height - paddle_height/2)
var paddle_disabled_on_collision_for = 0.75 #this is also referenced in the bounce fx
var velocity = Vector2.ZERO
var ball_to_track:Node2D = null
@onready var y_to_go_to = screen_middle
var reaction_time_min = 0.1 #seconds
var reaction_time_max = 0.25

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_in_group("Right Paddle"):
		$AnimatedSprite2D.flip_v = true #because the node in scene is just rotated 180 degrees
	AiEvents.ball_rebound.connect(_on_ai_event)
	AiEvents.ball_fired.connect(_on_ai_event)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if is_in_group("Keys Paddle"):
		key_movement()
		
	if is_in_group("Cursor Paddle"):
		cursor_movement()
			
	if is_in_group("AI Paddle"):
		ai_movement(delta)
	
	if velocity.y < 0:
		$AnimatedSprite2D.play("up")
	elif velocity.y > 0:
		$AnimatedSprite2D.play("down")
	else: $AnimatedSprite2D.play("default")
	
	position += velocity * delta
	if position.y > max_screen_can_travel: position.y = max_screen_can_travel
	if position.y < min_screen_can_travel: position.y = min_screen_can_travel
	
#disable paddle for a bit to make sure there's no shennanigans
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Ball"):
		
		shake_paddle(area.velocity.length())
		
		$CollisionShape2D.set_deferred("disabled", true)
		var timer = $"CollisionShape2D/Disable on Contact Timer"
		timer.start(paddle_disabled_on_collision_for)


func _on_disable_on_contact_timer_timeout() -> void:
	$CollisionShape2D.set_deferred("disabled", false)


func shake_paddle(ball_speed:float):
	#these numbers just felt good, no real math
	
	#600 is the ball starting speed at time of comment writing though
	var x_movement_baseline = 7
	var x_movement = x_movement_baseline + max(0, (ball_speed-600) / 40)
	
	#reverse the direction if facing the other way, of course
	if self.is_in_group("Right Paddle"): x_movement *= -1
	
	var impact_time = 0.15
	var original_position = position.x
	var target_position = original_position - x_movement
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:x", target_position, impact_time)
	await tween.finished
	
	#uses collision disable timer, cause that makes sense to me - could use a regular magic number
	var reset_time = (paddle_disabled_on_collision_for - impact_time) + 0.7
	tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:x", original_position, reset_time)


func key_movement():
	if Input.is_action_pressed("move_up"):
		velocity.y = -1
	elif Input.is_action_pressed("move_down"):
		velocity.y = 1
	else: velocity.y = 0
	
	velocity = velocity * paddle_speed_factor

func cursor_movement():
	var mouse_position = get_global_mouse_position()
	var paddle_position = position
	var mouse_difference_tolerance = 10
	
	if mouse_position.y - paddle_position.y > mouse_difference_tolerance:
		velocity.y = 1
	elif paddle_position.y - mouse_position.y > mouse_difference_tolerance:
		velocity.y = -1
	else: velocity.y = 0
	
	velocity = velocity * paddle_speed_factor
	

func ai_movement(_delta:float, override_reaction:bool = false):
	#set a goal
	
	#can override checking reaction time, like on ball rebound
	if override_reaction: track_ball_endpoint_at_current_velocity()
	##check if i can react yet
	#elif not override_reaction:
		##if not, do nothing but reduce wait time
		#if reaction_time_remaining > 0:
			#reaction_time_remaining -= delta
		##if so, reset reaction time, and react
		#if reaction_time_remaining <= 0:
			#reaction_time_remaining = randf_range(0.1,0.4)
			#track_ball_endpoint_at_current_velocity()
	
	#go to my goal
	#with a lil padding to clean up floating point issues
	if y_to_go_to-2 > position.y:
		velocity.y = 1
	elif y_to_go_to+2 < position.y:
		velocity.y = -1
	else: velocity.y = 0
	velocity.y = velocity.y * paddle_speed_factor


func track_ball_endpoint_at_current_velocity():
	#this currently ignores bounces, which i think is good
	#if i wanted it to think of bounces, i could check if the target y is outside of play area, if so by how much, then subtract that from play area height, to get estimated. can use modulo for multiple bounces
	
	#track a ball
	if not ball_to_track: ball_to_track = get_tree().get_first_node_in_group("Ball")
	
	#if the ball is to the right of the paddle, and is moving right; go to center
	if ball_to_track.position.x > position.x and ball_to_track.velocity.x > 0:
		y_to_go_to = y_coordinate_into_goal(screen_middle)
		
	#if the ball is to the left of the paddle, and is moving left; go to center
	elif ball_to_track.position.x < position.x and ball_to_track.velocity.x < 0:
		y_to_go_to = y_coordinate_into_goal(screen_middle)
		
	#otherwise, go catch the ball
	else:
		var x_ball_will_travel = position.x - ball_to_track.position.x
		var time_to_reach_x = x_ball_will_travel/ball_to_track.velocity.x
		var y_at_current_speed = ball_to_track.velocity.y * time_to_reach_x + ball_to_track.position.y

		y_to_go_to = y_coordinate_into_goal(y_at_current_speed)


func y_coordinate_into_goal(y_value: float) -> int:
	#returns a rounded int of a y coordinate that is somewhere on screen
	#and somewhere randomly non-centered on the paddle
	
	#move the goal a bit from the center of the paddle (for angular action)
	#size/2 is the furthest end point, so somewhere between center and that
	#okay /2 is too pixel perfect... bigger denominator
	var offset_range = paddle_height/2.3
	#could change this to a normal distribution, centering on 75%?
	var impact_point_offset = randf_range(-offset_range,offset_range)
	
	var goal = y_value + impact_point_offset
	#clamp to screen size, so it doesn't keep moving at edge of screen
	if goal > max_screen_can_travel: goal = max_screen_can_travel
	if goal < min_screen_can_travel: goal = min_screen_can_travel
	roundi(goal)
	return goal


func _on_ai_event():
	if self.is_in_group("AI Paddle"):
		#wait a lil for fake reaction time
		var wait_time = randf_range(reaction_time_min,reaction_time_max)
		await get_tree().create_timer(wait_time).timeout
		
		ai_movement(0, true)
