extends Area2D

var paddle_speed_factor = 500
var screen_size = 0 # init at ready
var paddle_disabled_on_collision_for = 0.2
var velocity = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size #going to use later for clamping
	
	
	if is_in_group("Right Paddle"):
		$AnimatedSprite2D.flip_v = true #because the node in scene is just rotated 180 degrees


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	velocity = Vector2.ZERO #clear old velocity
	
	if is_in_group("Keys Paddle"):
		key_movement()
		
	if is_in_group("Cursor Paddle"):
		cursor_movement()
			
	if is_in_group("AI Paddle"):
		ai_movement()

	if velocity.y < 0:
		$AnimatedSprite2D.play("up")
	elif velocity.y > 0:
		$AnimatedSprite2D.play("down")
	else: $AnimatedSprite2D.play("default")
	
	velocity = velocity * paddle_speed_factor
	position += velocity * delta
	var paddle_size = $CollisionShape2D.shape.get_rect().size
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
	if Input.is_action_pressed("move_down"):
		velocity.y = 1

func cursor_movement():
	var mouse_position = get_global_mouse_position()
	var paddle_position = position
	var mouse_difference_tolerance = 10
	
	if mouse_position.y - paddle_position.y > mouse_difference_tolerance:
		velocity.y = 1
	elif paddle_position.y - mouse_position.y > mouse_difference_tolerance:
		velocity.y = -1
		
func ai_movement():
	pass
