## Camera that can target positions or follow targeted nodes
## Should be positioned under the root scene.
class_name ActionCamera
extends Camera2D

@export var speed: float = .02
@export var step: float = 8
@export var target_node: Node2D

var timer: float = 0 
var target_position: Vector2

func _physics_process(delta: float) -> void:
	if target_node: 
		global_position = target_node.global_position
		return
	if position != target_position:
		timer += delta
		if timer > speed:
			timer -= speed
			position.x += clampf(target_position.x-position.x,-step,step)
			position.y += clampf(target_position.y-position.y,-step,step)
