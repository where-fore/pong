extends Node

@export var ball_scene: PackedScene
@onready var fade_parent = $"Scene Fade/ColorRect"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	
	if not self.has_meta("Main_Menu"):
		var fade_time = 2
		create_ball(fade_time) #delay on spawn to let it fade in, get bearings etc
		
		fade_parent.color = Color(0,0,0,1)
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_EXPO)
		tween.set_ease(Tween.EASE_IN)
		tween.tween_property(fade_parent, "color", Color(0,0,0,0), fade_time)
		await tween.finished
	else: create_ball()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func create_ball(drop_in_override:float = 0):
	var ball = ball_scene.instantiate()
	ball.position = ($"Ball Spawn".position)
	call_deferred("add_child", ball)
	ball.connect("destroyed", _on_ball_destroyed)
	
	if drop_in_override == 0:
		ball.call_deferred("drop_in")
	elif drop_in_override:
		ball.call_deferred("drop_in", drop_in_override)
	


func _on_left_wall_scored() -> void:
	create_ball()


func _on_right_wall_scored() -> void:
	create_ball()
	
	
func _on_ball_destroyed() -> void:
	create_ball()


func _on_main_menu_hud_start_game(scene: Variant) -> void:
	await fade_menu(Color(0,0,0,1), 2, fade_parent, "color")
	get_tree().change_scene_to_file(scene)


func fade_menu(target_color:Color, fade_time:float, target:Variant, target_property:String) -> bool:
	#assumes "var fade_in_out_tween = null" was instantiated
	var fade_in_out_tween = create_tween()
	fade_in_out_tween.set_trans(Tween.TRANS_CUBIC)
	fade_in_out_tween.set_ease(Tween.EASE_IN)
	fade_in_out_tween.tween_property(target, target_property, target_color, fade_time)
	
	#if you want to wait for the fade to be finished, await fade_menu()
	await fade_in_out_tween.finished
	fade_in_out_tween.kill()
	fade_in_out_tween = null
	return true


func _on_pause_menu_back_to_main_menu(scene: Variant) -> void:
	await fade_menu(Color(0,0,0,1), 1, fade_parent, "color")
	get_tree().change_scene_to_file(scene)
