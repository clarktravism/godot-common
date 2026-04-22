extends Node

const grid_size: Vector2 = Vector2(8, 8)
const grid_size_half: Vector2 = Vector2(4, 4)

func node_can_see(node: Node2D, target: Node2D, mask: int):
	var space_state = node.get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(node.global_position, target.global_position, mask)
	var result = space_state.intersect_ray(query)
	return result.size() == 0

func collision_at(node: Node2D, coords: Vector2, mask: int) -> Array:
	var space_state = node.get_world_2d().direct_space_state
	var params = PhysicsPointQueryParameters2D.new()
	params.position = coords + grid_size_half
	params.collision_mask = mask
	var results = space_state.intersect_point(params).map(func(x): return x["collider"])
	return results

#var new_coords = position + (dir * grid_size) 
#	var collisions = Physics.collision_at(self, new_coords + grid_size_half, 1)

func position_at_dir(node: Node2D, dir: Vector2) -> Vector2:
	return node.position + (dir * grid_size)
