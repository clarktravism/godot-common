extends Node2D
class_name GameObject

signal event_sent(value: StringName)

func _init() -> void:
	add_to_group("game_object")

func _ready() -> void:
	for x in get_children():
		if x.has_method(&"send"):
			event_sent.connect(Callable(x,&"send"))
		if x.has_signal(&"raise_event"):
			x.raise_event.connect(send)

func send(value: StringName) -> void:
	event_sent.emit(value)
