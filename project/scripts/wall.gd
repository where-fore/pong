extends Node2D

signal scored

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_area_entered(area: Area2D) -> void:
	if not is_in_group("Bounce Wall") and area.is_in_group("Ball"):
		emit_signal("scored")
		area.queue_free()
