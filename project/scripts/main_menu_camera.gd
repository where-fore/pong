extends Camera2D

var pan_tween
var pan_amount = 80
var pan_time = 8

var original_zoom
var zoom_amount = 1.1
var zoom_time = 4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_pan_tween()
	
	original_zoom = zoom
	start_zoom_tween()


func start_pan_tween():
	pan_tween = create_tween()
	pan_tween.set_trans(Tween.TRANS_SINE)
	pan_tween.set_ease(Tween.EASE_IN_OUT)
	pan_tween.tween_property(self, "offset", Vector2(pan_amount*(1280.0/720.0), pan_amount*(720.0/1280.0)), pan_time)
	pan_tween.tween_property(self, "offset", Vector2(-pan_amount*(1280.0/720.0), -pan_amount*(720.0/1280.0)), pan_time)
	pan_tween.set_loops()
	
	
func start_zoom_tween():
	pan_tween = create_tween()
	pan_tween.set_trans(Tween.TRANS_SINE)
	pan_tween.set_ease(Tween.EASE_IN_OUT)
	pan_tween.tween_property(self, "zoom", original_zoom*zoom_amount, zoom_time)
	pan_tween.tween_property(self, "zoom", original_zoom/zoom_amount, zoom_time)
	pan_tween.set_loops()
