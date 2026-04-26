extends TileMapLayer
class_name TileMapWriter

var _char_mod: int = 0
var _char_shift: int = 0

func _ready() -> void:
	_calc_char_mod_shift()

func _calc_char_mod_shift() -> void:
	if _char_mod != 0 && _char_shift != 0:
		return
	if tile_set:
		var source = tile_set.get_source(tile_set.get_source_id(0)) as TileSetAtlasSource
		var grid_size = source.get_atlas_grid_size()
		_char_mod = grid_size.x - 1
		_char_shift = floori(sqrt(grid_size.x))

func write_character(coords: Vector2i, character: int, source_id: int) -> void:
	_print_char(coords, character, source_id)

func write_string(coords: Vector2i, text: String, source_id: int) -> void:
	write_bytes(coords, text.to_ascii_buffer(), source_id)

func write_bytes(coords: Vector2i, bytes: PackedByteArray, source_id: int) -> void:
	for i in range(bytes.size()):
		_print_char(coords, bytes[i], source_id)
		coords.x += 1

func _print_char(coords: Vector2i, character: int, source_id: int) -> void:
	set_cell(coords, source_id, Vector2i(character & _char_mod, character >> _char_shift))
