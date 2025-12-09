extends CanvasLayer

var startup_timer = 0 #countdown to start the game

signal intro_finished
signal start_game(scene)

@export_file("*.tscn") var computer_play_scene
@export_file("*.tscn") var local_play_scene
@onready var fade = $CanvasModulate


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#hides the canvas, so it can be visible in editor
	$CanvasModulate.color = Color(1,1,1,0)
	
	await get_tree().create_timer(3.4).timeout
	emit_signal("intro_finished")
	fade_in()
	

func fade_in() -> bool:
	var fade_in_out_tween = create_tween()
	fade_in_out_tween.set_trans(Tween.TRANS_EXPO)
	fade_in_out_tween.set_ease(Tween.EASE_OUT)
	fade_in_out_tween.tween_property(fade, "color", Color(1,1,1,1), 1)
	
	#if you want to wait for the fade to be finished, await
	await fade_in_out_tween.finished
	fade_in_out_tween.kill()
	fade_in_out_tween = null
	return true

func start_a_game(scene) -> void:
	#$"CanvasModulate/Start Countdown".show()
	#$"CanvasModulate/Start Countdown/Start Countdown Timer".start(startup_timer)
	#await get_tree().create_timer(startup_timer).timeout
	emit_signal("start_game", scene)


func _on_start_countdown_timer_timeout() -> void:
	$"CanvasModulate/Start Countdown".hide()


func _on_start_button_vs_computer_pressed() -> void:
	start_a_game(computer_play_scene)


func _on_start_button_vs_local_pressed() -> void:
	start_a_game(local_play_scene)
