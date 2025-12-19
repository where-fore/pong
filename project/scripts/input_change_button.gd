extends Control
#this is intentionally only attached to the visible border & text
#otherwise the button would scale to 0 and wouldn't be clickable

signal input_button_first_pressed

var button_pressed_once = false
var pulse_tween = null
var bounce_tween = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#save scale that was set in editor, then set to 0 to prep fade in
	var original_property_value = self.scale
	self.scale = Vector2.ZERO
	
	#wait while it fades in and stuff
	var wait_time = 1.25 #seconds
	await get_tree().create_timer(wait_time).timeout
	
	#bounce in
	var bounce_in_time = 0.6
	bounce_tween = create_tween()
	bounce_tween.set_trans(Tween.TRANS_SPRING)
	bounce_tween.set_ease(Tween.EASE_OUT)
	bounce_tween.tween_property(self, "scale", original_property_value, bounce_in_time) #goes to target value
	
	await get_tree().create_timer(bounce_in_time+0.5).timeout
	
	#pulse a bit
	
	#check if there's a pulse tween already, if not do nothing
	if not pulse_tween:
		pulse_tween = create_tween()
		var target = self
		var target_property = "scale"
		var duration = 1
		var change_factor = 1.1
		
		pulse_tween.set_trans(Tween.TRANS_LINEAR)
		pulse_tween.tween_property(target, target_property, original_property_value, duration) #goes to target value
		pulse_tween.tween_property(target, target_property, original_property_value*change_factor, duration) #goes back to cached original value
		#pulse forever.. until the stop_tweens function gets called
		pulse_tween.set_loops()


func stop_tweens():
	#after a bit, so you know you can double click to reset
	var wait_time = 2 #seconds
	await get_tree().create_timer(wait_time).timeout
	
	if bounce_tween: bounce_tween.stop()
	if pulse_tween: pulse_tween.stop()
	pulse_tween = create_tween()
	pulse_tween.set_trans(Tween.TRANS_CIRC)
	pulse_tween.set_ease(Tween.EASE_IN)
	pulse_tween.tween_property(self, "scale", Vector2.ZERO, 0.75) #goes to target value


func _on_input_change_button_pressed() -> void:
	if not button_pressed_once:
		button_pressed_once = true
		emit_signal("input_button_first_pressed")
		stop_tweens() #this has a delay, check the function
