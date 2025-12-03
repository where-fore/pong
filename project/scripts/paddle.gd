extends Area2D

var paddle_speed_factor = 500
var screen_size = 0 #init at ready
var paddle_size = 0 #init at ready
var paddle_disabled_on_collision_for = 0.2
var velocity = Vector2.ZERO
var ball_to_track = null
var reaction_time_remaining = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size #going to use later for clamping
	paddle_size = $CollisionShape2D.shape.get_rect().size

	if is_in_group("Right Paddle"):
		$AnimatedSprite2D.flip_v = true #because the node in scene is just rotated 180 degrees


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if is_in_group("Keys Paddle"):
		key_movement()
		
	if is_in_group("Cursor Paddle"):
		cursor_movement()
			
	if is_in_group("AI Paddle"):
		if not ball_to_track:
			ball_to_track = get_tree().get_first_node_in_group("Ball")
		ai_movement(delta)

	if velocity.y < 0:
		$AnimatedSprite2D.play("up")
	elif velocity.y > 0:
		$AnimatedSprite2D.play("down")
	else: $AnimatedSprite2D.play("default")
	
	position += velocity * delta
	position = position.clamp(Vector2.ZERO+paddle_size/2, (screen_size - paddle_size/2))

#disable paddle for a bit to make sure there's no shennanigans
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Ball"):
		$CollisionShape2D.disabled = true
		await get_tree().create_timer(paddle_disabled_on_collision_for).timeout
		$CollisionShape2D.disabled = false

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
	

func ai_movement(delta):
	reaction_time_remaining -= delta
	if reaction_time_remaining <= 0:
		reaction_time_remaining = 0 #randf_range(0,0.03)
		track_ball_endpoint_at_current_velocity()


func track_y_directly():
	go_to_point(ball_to_track.position.y)


func track_ball_endpoint_at_current_velocity():
	var x = abs(position.x - ball_to_track.position.x)
	var y = abs(position.y - ball_to_track.position.y)
	var time_to_reach_x = x/ball_to_track.velocity.x
	var time_to_reach_y = y/ball_to_track.velocity.y
	var time_to_react = min(abs(time_to_reach_x), abs(time_to_reach_y))
	var y_at_current_speed = ball_to_track.velocity.y * time_to_react + ball_to_track.position.y

	go_to_point(y_at_current_speed)


func go_to_point(point: float):
	# divides by 4 to check for middle of each end (75%) (divide by 2 would check ends)
	if point > (position + paddle_size/4).y:
		velocity.y = 1
	elif point < (position - paddle_size/4).y:
		velocity.y = -1
	else: velocity.y = 0
	
	velocity = velocity * paddle_speed_factor
