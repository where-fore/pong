extends TextureRect

func change_icon(new_icon:CompressedTexture2D):
	self.texture = new_icon
	
	var tween = create_tween()
	var target = self
	var target_property = "scale"
	var duration = 0.4
	var original_property_value = self.scale
	var change_factor = 1.06
	var target_property_value = original_property_value * change_factor
	
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(target, target_property, target_property_value, duration)
	tween.tween_property(target, target_property, original_property_value, duration)
