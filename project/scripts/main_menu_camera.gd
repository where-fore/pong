extends Camera2D

var pan_amount = 60
var pan_time = 12

var first_zoom_time = 3.8
var original_zoom = Vector2(0.95, 0.95)
var zoom_amount = 1.10
var zoom_time = 6

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(1).timeout
	await first_zoom()
	#start_pan_tween()
	start_zoom_tween()


func first_zoom() -> bool:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "zoom", original_zoom, first_zoom_time)
	await tween.finished
	return true


func start_pan_tween():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "offset", Vector2(pan_amount*(1280.0/720.0), pan_amount*(720.0/1280.0)), pan_time)
	tween.tween_property(self, "offset", Vector2(-pan_amount*(1280.0/720.0), -pan_amount*(720.0/1280.0)), pan_time)
	tween.set_loops()
	
	
func start_zoom_tween():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "zoom", original_zoom/zoom_amount, zoom_time)
	tween.tween_property(self, "zoom", original_zoom, zoom_time)
	tween.set_loops()
