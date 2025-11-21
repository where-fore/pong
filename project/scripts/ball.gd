extends Area2D

signal destroyed

var ball_speed = 600
var velocity = Vector2.ZERO
var acceleration_factor = 1.12 #to give the game a ramping time limit
var random_starting_direction_tilt = 0.3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Ball")
	
	#shoot ball, in a bit of a random direction after a delay
	var ball_spawn_shoot_delay = 2
	await get_tree().create_timer(ball_spawn_shoot_delay).timeout
	
	var up_or_down = randi_range(0,1)
	if up_or_down == 0: up_or_down = -1
	var random_tilt = randf_range(0.1, 0.1+random_starting_direction_tilt)
	
	var left_or_right = randi_range(0,1)
	if left_or_right == 0: left_or_right = -1
	
	velocity = Vector2.LEFT*left_or_right + Vector2.UP*up_or_down*random_tilt
	velocity *= ball_speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += velocity * delta
	

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Paddle"):
		velocity *= acceleration_factor
		velocity *= Vector2(-1,1)
		
	elif area.is_in_group("Bounce Wall"):
		velocity *= Vector2(1,-1)
	
	#failsafe: checks if it has collided with something recently
	#if not it's probably out of bounds, so yeet
	$Timer.start() #restart timer


func _on_timer_timeout() -> void:
	emit_signal("destroyed")
	queue_free()
