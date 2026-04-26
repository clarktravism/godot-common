extends GameObject

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		send(&"ui_cancel")

func _on_closed_entered() -> void:
	get_tree().paused = false
	hide()

func _on_open_entered() -> void:
	get_tree().paused = true
	show()
