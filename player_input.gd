extends Node

@export var movement: GridMovement
@export var state_machine: StateMachine
@onready var timer: Timer = $Timer

func _physics_process(_delta: float) -> void:
	if !timer.is_stopped() || state_machine.has_state_tag("locked"):
		return
	if Input.is_action_pressed("ui_up") && !Input.is_action_pressed("ui_down"):
		movement.try_step(Vector2.UP)
		timer.start()
		return
	if Input.is_action_pressed("ui_down") && !Input.is_action_pressed("ui_up"):
		movement.try_step(Vector2.DOWN)
		timer.start()
		return
	if Input.is_action_pressed("ui_left") && !Input.is_action_pressed("ui_right"):
		movement.try_step(Vector2.LEFT)
		timer.start()
		return
	if Input.is_action_pressed("ui_right") && !Input.is_action_pressed("ui_left"):
		movement.try_step(Vector2.RIGHT)
		timer.start()
		return
