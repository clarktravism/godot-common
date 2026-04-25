@tool
extends Sprite2D
class_name TileSetSprite

@export var tile_set: TileSet:
	get: return tile_set
	set(value):
		tile_set = value
		_update_texture()

@export var source_index: int:
	get: return source_index
	set(value):
		source_index = value
		_update_texture()

func _ready() -> void:
	_update_texture()

func _update_texture() -> void:
	if tile_set && source_index < tile_set.get_source_count() && source_index >= 0:
		var source = tile_set.get_source(tile_set.get_source_id(source_index)) as TileSetAtlasSource
		if source:
			texture = source.texture
			var size = source.get_atlas_grid_size()
			hframes = size.x
			vframes = size.y
