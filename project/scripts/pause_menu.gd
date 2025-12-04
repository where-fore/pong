extends CanvasLayer

@export_file("*.tscn") var main_menu_scene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	if main_menu_scene == null:
		push_error("Exported variable is null")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause menu") and not get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("pause menu") and get_tree().paused:
		unpause()

func pause():
	get_tree().paused = true
	
	$MenuBody.modulate.a = 0
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($MenuBody, "modulate", Color(1,1,1,1), 0.3)
	visible = true
		
		
func unpause():
	$MenuBody.modulate.a = 1
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($MenuBody, "modulate", Color(1,1,1,0), 0.4)
	
	await tween.finished
	
	get_tree().paused = false
	visible = false
	
	var ball_array = get_tree().get_nodes_in_group("Ball")
	for ball in ball_array:
		ball.drop_in()
	


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu_scene)
