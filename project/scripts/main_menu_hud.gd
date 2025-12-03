extends CanvasLayer

var startup_timer = 3 #countdown to start the game

@export_file("*.tscn") var solo_play_scene
@export_file("*.tscn") var multi_play_scene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_start_button_pressed() -> void:
	$"Start Button".hide()
	$"Start Countdown".show()
	$"Start Countdown/Start Countdown Timer".start(startup_timer)
	await get_tree().create_timer(startup_timer).timeout #nothing to wait for
	get_tree().change_scene_to_file(solo_play_scene)


func _on_start_countdown_timer_timeout() -> void:
	$"Start Countdown".hide()
