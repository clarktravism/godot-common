extends Node
class_name State

signal entered()
signal exited()

@export var on: Dictionary[StringName,State]
@export var tags: Array[StringName]

func _init() -> void:
	add_to_group("state")

func exit() -> void:
	exited.emit()

func enter() -> void:
	entered.emit()
