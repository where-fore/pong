extends CanvasLayer

@export_file("*.tscn") var main_menu_scene
@onready var menu_body = $Container/MenuBody
var pulse_tween = null
var fade_in_out_tween = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#sometimes it's set to visible in the editor so i can work, this makes sure it doesn't start visible
	visible = false
	menu_body.modulate = 0
	
	if main_menu_scene == null:
		push_error("Exported variable is null")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause menu") and not get_tree().paused:
		open_menu()
	elif Input.is_action_just_pressed("pause menu") and get_tree().paused and not fade_in_out_tween:
		close_menu()


func open_menu():
	pause()
	pulse_menu()
	
	visible = true
	fade_menu(Color(1,1,1,1), 0.2)


func close_menu():
	var fade_time = 0.3
	
	#stop the pulsing non-menu fade
	pulse_menu(false, fade_time)
	
	#fade out whole menu
	await fade_menu(Color(1,1,1,0), fade_time)
	
	unpause()
	visible = false


func pause():
	get_tree().paused = true


func unpause():	
	get_tree().paused = false
	
	var ball_array = get_tree().get_nodes_in_group("Ball")
	for ball in ball_array:
		ball.drop_in()


func pulse_menu(start = true, time_to_kill = 0):
	#currently this just infinitely pulses it, even though the menu never closes, it just hides
	#this is probably fine cause it costs nothing and looks unnoticeable
	var target = $Container/"Non Menu Fade Layer"
	var min_alpha = 0.5
	var max_alpha = 0.7
	var initial_fade_time = 0.3
	var pulse_time = 4
	if start and not pulse_tween:
		pulse_tween = create_tween()
		pulse_tween.set_trans(Tween.TRANS_LINEAR)
		#pulse_tween.set_ease(Tween.EASE_OUT_IN) #if you want a non-linear easing
		
		#inital fade out
		pulse_tween.tween_property(target, "color", Color(0,0,0,min_alpha), initial_fade_time)
		await pulse_tween.finished
		pulse_tween.stop()
		
		#start pulsing fading
		pulse_tween.tween_property(target, "color", Color(0,0,0,max_alpha), pulse_time)
		pulse_tween.play()
		pulse_tween.tween_property(target, "color", Color(0,0,0,min_alpha), pulse_time)
		pulse_tween.set_loops() #infinite
	elif not start:
		if pulse_tween:
			pulse_tween.kill()
			pulse_tween = null
		
		var kill_tween = create_tween()
		kill_tween.set_trans(Tween.TRANS_LINEAR)
		kill_tween.tween_property(target, "color", Color(0,0,0,0), time_to_kill)


func fade_menu(target_color:Color, fade_time:float) -> bool:
	#clean up old
	if fade_in_out_tween:
		fade_in_out_tween.kill()
		fade_in_out_tween = null
	
	fade_in_out_tween = create_tween()
	fade_in_out_tween.set_trans(Tween.TRANS_CUBIC)
	fade_in_out_tween.set_ease(Tween.EASE_IN)
	fade_in_out_tween.tween_property(menu_body, "modulate", target_color, fade_time)
	#if you want to wait for the fade to be finished, await fade_menu()
	await fade_in_out_tween.finished
	fade_in_out_tween.kill()
	fade_in_out_tween = null
	return true


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu_scene)


func _on_close_button_pressed() -> void:
	close_menu()
