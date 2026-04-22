@tool
extends Resource
class_name GeneratePalettedTileset

@export var texture: Texture2D
@export var palette: Texture2D
@export var tile_height: int = 8
@export var tile_width: int = 8
@export_file("*.res") var out_path: String = ""

@export_tool_button("Generate")
var generate_action = _generate

var _tile_size: Vector2i

func _generate() -> void:
	if _check_exports():
		return
	_tile_size = Vector2i(tile_width, tile_height)
	print(_tile_size)
	var tileset = _get_tileset()
	var colors = _get_colors()
	for i in range(1, colors.size()):
		var tex = _create_texture_with_colors(colors[i], colors[0])
		_set_texture_to_source(tileset, i-1, tex)
	ResourceSaver.save(tileset, out_path, ResourceSaver.FLAG_BUNDLE_RESOURCES)

func _check_exports() -> bool:
	if texture == null:
		print("texture is null")
		return true
	if palette == null:
		print("palette is null")
		return true
	if out_path == "":
		print("out_path is blank")
		return true
	if tile_height == 0 || tile_width == 0:
		print("tile size is 0")
		return true
	return false

func _get_tileset() -> TileSet:
	var tileset: TileSet
	if ResourceLoader.exists(out_path, "TileSet"):
		tileset = ResourceLoader.load(out_path, "TileSet")
		if _is_tileset_dim_diff(tileset):
			_clear_tileset(tileset)
		tileset.tile_size = _tile_size
	else:
		tileset = TileSet.new()
		tileset.tile_size = _tile_size
	return tileset

# returns true if tile size or texture size is different
func _is_tileset_dim_diff(tileset: TileSet) -> bool:
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

func _clear_tileset(tileset: TileSet) -> void:
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

func _set_texture_to_source(tileset: TileSet, index: int, value: Texture2D) -> void:
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
		print("region_size", source.texture_region_size)
		source.resource_name = "Color " + str(index)
		var grid_size = source.get_atlas_grid_size()
		for y in grid_size.y:
			for x in grid_size.x:
				source.create_tile(Vector2i(x, y))
		print("grid_size", grid_size)
		return source
