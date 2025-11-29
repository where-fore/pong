extends Area2D

signal destroyed
var velocity = Vector2.ZERO #instantiates
var bounce_count_parent

#base ball settings
var ball_speed = 600
var random_starting_direction_tilt = 0.3 # how far from horizontal to start the ball moving
var rotational_speed_factor = 0.008
var ball_spawn_shoot_delay = 2.2
var ball_pulse_growth_factor = 2

#acceleration on paddle bounce
var acceleration_factor = 1.08 #to give the game a ramping time limit
var accelerate_x = true
var accelerate_y = false

#rebound at non-45 on paddle bounce: as a factor of distance to center of paddle on collision
var use_angle_rebound = true
var rebound_angle_factor = 0.5
#two purposes: bandaid to solve the ball center issue, and could be used to limit the power of edge bounces
var clamp_rebound_edges = true
var clamp_rebound_edge_max = 0.85 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Ball")
	
	#set up a random direction and angle
	var up_or_down = randi_range(0,1)
	if up_or_down == 0: up_or_down = -1
	var random_tilt = randf_range(0.1, 0.1+random_starting_direction_tilt)
	
	var left_or_right = randi_range(0,1)
	if left_or_right == 0: left_or_right = -1
	
	velocity = Vector2.LEFT*left_or_right + Vector2.UP*up_or_down*random_tilt
	velocity *= ball_speed
	
	#animate then fire
	drop_in()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += velocity * delta
	rotation_degrees += rotational_speed_factor*velocity.x
	

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Paddle"):
		# known issue: this math isn't perfectly accurate since i'm not measuring where the ball impacted the paddle
		var ball_pos = position.y #this is the center of the ball, not the position of the collision
		var paddle_pos = area.position.y
		var distance_to_paddle_center = abs(ball_pos - paddle_pos)
		var paddle_length_to_center = area.get_node("CollisionShape2D").shape.height/2
		var percent_of_paddle_from_center = distance_to_paddle_center / paddle_length_to_center
		
		if clamp_rebound_edges: 
			percent_of_paddle_from_center = min(percent_of_paddle_from_center, clamp_rebound_edge_max)

		if use_angle_rebound:
			velocity *= (Vector2(1, 1+(percent_of_paddle_from_center*rebound_angle_factor)))
		if accelerate_x:
			velocity.x *= acceleration_factor
		if accelerate_y:
			velocity.y *= acceleration_factor

		velocity *= Vector2(-1,1) #basic reverse direction
		
		HudEvents.ball_bounced.emit()
		
	elif area.is_in_group("Bounce Wall"):
		velocity *= Vector2(1,-1)
	
	#failsafe: checks if it has collided with something recently
	#restarts timer when colliding with anything
	$Timer.start() #restart timer

#failsafe: checks if it has collided with something recently
#if it hasn't collided in a while, yeet
func _on_timer_timeout() -> void:
	emit_signal("destroyed")
	queue_free()

func drop_in():
	$Timer.start() #restart collision timer
	
	var base_scale = $Sprite2D.scale
	var base_velocity = velocity
	velocity = Vector2.ZERO
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property($Sprite2D, "scale", base_scale*ball_pulse_growth_factor, ball_spawn_shoot_delay/2)
	tween.tween_property($Sprite2D, "scale", base_scale, ball_spawn_shoot_delay/2)
	await tween.finished
	velocity = base_velocity
	
	$Timer.start() #restart collision timer
