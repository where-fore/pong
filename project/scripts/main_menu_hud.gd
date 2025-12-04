extends CanvasLayer

var startup_timer = 3 #countdown to start the game

@export_file("*.tscn") var computer_play_scene
@export_file("*.tscn") var local_play_scene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func start_a_game(scene) -> void:
	$"Start Countdown".show()
	$"Start Countdown/Start Countdown Timer".start(startup_timer)
	await get_tree().create_timer(startup_timer).timeout #nothing to wait for
	get_tree().change_scene_to_file(scene)


func _on_start_countdown_timer_timeout() -> void:
	$"Start Countdown".hide()


func _on_start_button_vs_computer_pressed() -> void:
	start_a_game(computer_play_scene)


func _on_start_button_vs_local_pressed() -> void:
	start_a_game(local_play_scene)
