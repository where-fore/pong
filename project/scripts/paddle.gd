extends Area2D

var paddle_speed_factor = 500
@onready var screen_size = get_viewport_rect().size
@onready var paddle_size = $CollisionShape2D.shape.get_rect().size
var paddle_disabled_on_collision_for = 0.75 #this is also referenced in the bounce fx
var velocity = Vector2.ZERO
var ball_to_track = null
var reaction_time_remaining = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
		if ball_to_track: ai_movement(delta)
	
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
		
		shake_paddle(area.velocity.length())
		
		$CollisionShape2D.set_deferred("disabled", true)
		var timer = $"CollisionShape2D/Disable on Contact Timer"
		timer.start(paddle_disabled_on_collision_for)


func _on_disable_on_contact_timer_timeout() -> void:
	$CollisionShape2D.set_deferred("disabled", false)


func shake_paddle(ball_speed:float):
	#these numbers just felt good, no real math
	#600 is the ball starting speed at time of comment writing though
	var x_movement = 7 + max(0, (ball_speed-600) / 28)
	
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
	var reset_time = paddle_disabled_on_collision_for - impact_time
	tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
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
