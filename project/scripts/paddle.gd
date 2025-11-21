extends Area2D

var paddle_speed_factor = 500
var screen_size = 0
var paddle_type = "Keys"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	if is_in_group("Cursor Paddle"):
		paddle_type= "Cursor"
		$AnimatedSprite2D.flip_v = true #because the node in scene is just rotated 180 degrees


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity = Vector2.ZERO
	
	if paddle_type == "Keys":
		if Input.is_action_pressed("move_up"):
			velocity.y = -1
		if Input.is_action_pressed("move_down"):
			velocity.y = 1
		
	if paddle_type == "Cursor":
		var mouse_position = get_global_mouse_position()
		var paddle_position = position
		var mouse_difference_tolerance = 20
		if mouse_position.y - paddle_position.y > mouse_difference_tolerance:
			velocity.y = 1
		elif paddle_position.y - mouse_position.y > mouse_difference_tolerance:
			velocity.y = -1
		
		
	if velocity.y < 0:
		$AnimatedSprite2D.play("up")
	elif velocity.y > 0:
		$AnimatedSprite2D.play("down")
	else: $AnimatedSprite2D.play("default")
	
	velocity = velocity * paddle_speed_factor
	position += velocity * delta
	var paddle_size = $CollisionShape2D.shape.get_rect().size
	position = position.clamp(Vector2.ZERO+paddle_size/2, (screen_size - paddle_size/2))
