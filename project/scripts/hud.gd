extends CanvasLayer

signal start_game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	var startup_timer = 3
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


func _on_left_wall_scored() -> void:
	$"Cursor Score Icon/Cursor Score Label".show()
	$"Cursor Score Icon/Cursor Score Label".text = str(int($"Cursor Score Icon/Cursor Score Label".text) + 1)
