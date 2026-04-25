@tool
extends Resource
class_name GeneratePalettedTileset

@export var texture: Texture2D
@export var palette: Texture2D
@export var tile_height: int = 8
@export var tile_width: int = 8
@export var tileset: TileSet

@export_tool_button("Generate Sources")
var generate_action = _generate

# copies Tile Data from source 0 to all other sources
@export_tool_button("Propagate Tile Data")
var sync_tile_data_action = _sync_tile_data

var _tile_size: Vector2i

func _generate() -> void:
	if _check_exports():
		return
	_tile_size = Vector2i(tile_width, tile_height)
	_setup_tileset()
	var colors = _get_colors()
	for i in range(1, colors.size()):
		var tex = _create_texture_with_colors(colors[i], colors[0])
		_set_texture_to_source(i-1, tex)
	_save_tileset()

func _save_tileset() -> void:
	if tileset.resource_path == "":
		print("need resource path")
		return
	var err = ResourceSaver.save(tileset)
	if err != OK:
		print("error saving:", err)
	var editor_resfs = EditorInterface.get_resource_filesystem()
	editor_resfs.update_file(tileset.resource_path)
	# throws errors
	#editor_resfs.reimport_files(PackedStringArray([tileset.resource_path]))

func _check_exports() -> bool:
	if texture == null:
		print("texture is null")
		return true
	if palette == null:
		print("palette is null")
		return true
	if tileset == null:
		print("tileset is null")
		return true
	if tile_height == 0 || tile_width == 0:
		print("tile size is 0")
		return true
	return false

func _setup_tileset() -> void:
	if _is_tileset_dim_diff():
		_clear_tileset()
		tileset.tile_size = _tile_size

# returns true if tile size or texture size is different
func _is_tileset_dim_diff() -> bool:
	if tileset.tile_size != _tile_size:
		return true
	if tileset.get_source_count() == 0:
		return false
	var source = tileset.get_source(tileset.get_source_id(0)) as TileSetAtlasSource
	if source.texture.get_size() != texture.get_size():
		return true
	if source.texture_region_size != _tile_size:
		return true
	return false

func _clear_tileset() -> void:
	while tileset.get_source_count() > 0:
		tileset.remove_source(tileset.get_source_id(0))

func _get_colors() -> PackedColorArray:
	var colors: PackedColorArray = PackedColorArray()
	var img = palette.get_image()
	for y in img.get_height():
		for x in img.get_width():
			var color = img.get_pixel(x, y)
			if !colors.has(color):
				colors.append(color)
	return colors
	
func _create_texture_with_colors(fg: Color, bg: Color) -> Texture2D:
	var src_img = texture.get_image()
	var img = Image.create_empty(src_img.get_width(), src_img.get_height(), false, Image.FORMAT_RGBA8)
	for y in src_img.get_height():
		for x in src_img.get_width():
			var pc = src_img.get_pixel(x, y)
			if pc == Color.BLACK:
				img.set_pixel(x, y, bg)
			else:
				img.set_pixel(x, y, fg)
	return ImageTexture.create_from_image(img)

func _set_texture_to_source(index: int, value: Texture2D) -> void:
	if index < tileset.get_source_count():
		var source = tileset.get_source(tileset.get_source_id(index)) as TileSetAtlasSource
		source.texture = value
	else:
		var source = _create_tileset_source(value, index)
		tileset.add_source(source, index)

func _create_tileset_source(value: Texture2D, index: int) -> TileSetAtlasSource:
		var source: TileSetAtlasSource = TileSetAtlasSource.new()
		source.texture = value
		source.texture_region_size = _tile_size
		source.resource_name = "Color " + str(index)
		var grid_size = source.get_atlas_grid_size()
		for y in grid_size.y:
			for x in grid_size.x:
				source.create_tile(Vector2i(x, y))
		return source

func _sync_tile_data() -> void:
	if tileset == null:
		return
	if tileset.get_source_count() < 2:
		return
	
	var base_source = tileset.get_source(tileset.get_source_id(0)) as TileSetAtlasSource
	for i in range(1, tileset.get_source_count()):
		var source = tileset.get_source(tileset.get_source_id(i)) as TileSetAtlasSource
		_sync_sources(base_source, source)
	
	_save_tileset()

func _sync_sources(base_source: TileSetAtlasSource, source: TileSetAtlasSource) -> void:
	var physics_layers = tileset.get_physics_layers_count()
	var grid_size = source.get_atlas_grid_size()
	for y in grid_size.y:
		for x in grid_size.x:
			var b_data = base_source.get_tile_data(Vector2i(x,y), 0)
			var t_data = source.get_tile_data(Vector2i(x,y), 0)
			# collision
			for pl in range(physics_layers):
				t_data.set_collision_polygons_count(pl, b_data.get_collision_polygons_count(pl))
				for i in range(b_data.get_collision_polygons_count(pl)):
					var polygon = b_data.get_collision_polygon_points(pl, i)
					t_data.set_collision_polygon_points(pl, i, polygon)
					var oneway = b_data.is_collision_polygon_one_way(pl, i)
					t_data.set_collision_polygon_one_way(pl, i, oneway)
					var margin = b_data.get_collision_polygon_one_way_margin(pl, i)
					t_data.set_collision_polygon_one_way_margin(pl, i, margin)
