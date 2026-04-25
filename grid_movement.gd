extends Node
class_name GridMovement

@export var grid_size: Vector2 = Vector2(8, 8)
@export_flags_2d_physics var layer: int = 0
@export_flags_2d_physics var mask: int = 0
@export var hit_event: StringName
@export var node2d: Node2D
var grid_size_half: Vector2

func _ready() -> void:
	grid_size_half = grid_size / 2

func try_step(dir: Vector2) -> bool:
	var new_coords = node2d.position + (dir * grid_size)
	# mask gets hit event
	if !hit_event.is_empty():
		var mc = collision_at(new_coords)
		for x in mc:
			if x.is_in_group("hit_body"):
				x.hit_event(hit_event)
	# layer blocks movement
	if collision_at(new_coords).size() > 0:
		return false
	node2d.position = new_coords
	return true

func collision_at(coords: Vector2) -> Array:
	var space_state = node2d.get_world_2d().direct_space_state
	var params = PhysicsPointQueryParameters2D.new()
	params.position = coords + grid_size_half
	params.collision_mask = mask
	var results = space_state.intersect_point(params).map(func(x): return x["collider"])
	return results
