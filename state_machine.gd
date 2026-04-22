extends Node
class_name StateMachine

signal state_changed(value: State)

@export var initial_state: State
var state: State

func _init() -> void:
	add_to_group("state_machine")

func _ready() -> void:
	_set_state(initial_state)

func _set_state(value: State) -> void:
	if value == null:
		return
	if state:
		state.exit()
	state = value
	state.enter()
	state_changed.emit(state)

func reset() -> void:
	_set_state(initial_state)

#send 'event' to transition to another state
func send(event: StringName) -> void:
	var next_state = state.on.get(event, null)
	if next_state == null:
		return
	_set_state(next_state)

func get_state() -> StringName:
	if state:
		return state.name
	return ""

func get_state_tags() -> Array[StringName]:
	if state:
		return state.tags
	return []
