extends Node

@export var ball_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func create_ball():
	var ball = ball_scene.instantiate()
	ball.position = ($"Ball Spawn".position)
	call_deferred("add_child", ball)
	ball.connect("destroyed", _on_ball_destroyed)


func _on_hud_start_game() -> void:
	create_ball()


func _on_left_wall_scored() -> void:
	create_ball()


func _on_right_wall_scored() -> void:
	create_ball()
	
	
func _on_ball_destroyed() -> void:
	create_ball()
