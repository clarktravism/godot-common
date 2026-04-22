extends StaticBody2D
class_name HitBody

signal raise_event(event: StringName)

func _init() -> void:
	add_to_group("hit_body")

func hit_event(event: StringName) -> void:
	raise_event.emit(event)
