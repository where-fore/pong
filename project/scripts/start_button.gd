extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	disabled = true

func _on_main_menu_hud_intro_finished() -> void:
	disabled = false
