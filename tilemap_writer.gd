extends Node
class_name TileMapWriter

@export var tile_map_layer: TileMapLayer
@export var offset: Vector2i = Vector2i(0, 0)
@export var text_width: int = 24
# number of characters past the word wrap before it hyphenates
@export var hyphen_min: int = 8

var _char_mod: int = 0
var _char_shift: int = 0
var _cursor_coords: Vector2i

func _calc_char_mod_shift() -> void:
	if _char_mod != 0 && _char_shift != 0:
		return
	if tile_map_layer && tile_map_layer.tile_set:
		var source = tile_map_layer.tile_set.get_source(tile_map_layer.tile_set.get_source_id(0)) as TileSetAtlasSource
		var grid_size = source.get_atlas_grid_size()
		_char_mod = grid_size.x - 1
		_char_shift = floori(sqrt(grid_size.x))

func clear() -> void:
	_cursor_coords = Vector2i(0, 0)
	if tile_map_layer:
		tile_map_layer.clear()

func set_cursor(value: Vector2i) -> void:
	_cursor_coords = value

# writes a new line, with a new line at the end
func write_line(text: String, source_index: int = 0) -> void:
	var coords = _print_text(_cursor_coords, text, source_index)
	_cursor_coords = Vector2i(0, coords.y+1)

func write(text: String, source_index: int = 0) -> void:
	_cursor_coords = _print_text(_cursor_coords, text, source_index)

# write text at the coords, doesn't use cursor
func write_at(coords: Vector2i, text: String, source_index: int = 0) -> void:
	_print_text(coords, text, source_index)

func _print_text(coords: Vector2i, text: String, source_index: int = 0) -> Vector2i:
	_calc_char_mod_shift()
	var source_id = tile_map_layer.tile_set.get_source_id(source_index)
	var buffer = text.to_ascii_buffer()
	var word = PackedByteArray()
	for i in range(buffer.size()):
		if buffer[i] == 13: continue
		#flush word
		if buffer[i] == 32 || buffer[i] == 10:
			word.append(32)
			coords = _print_word(coords, word, source_id)
			word.clear()
			# new line
			if buffer[i] == 10:
				coords.x = 0
				coords.y += 1
			continue
		#word wrap
		if i+1 != buffer.size() && buffer[i+1] != 32 && buffer[i+1] != 10:
			if coords.x + word.size() > text_width:
				if word.size() < hyphen_min:
					coords.x = 0
					coords.y += 1
				else: #hyphenation
					word.append(45)
					coords = _print_word(coords, word, source_id)
					word.clear()
					coords.x = 0
					coords.y += 1
		#copy character to word
		word.append(buffer[i])
	# final word
	coords = _print_word(coords, word, source_id)
	return coords

func _print_word(coords: Vector2i, word: PackedByteArray, source_id: int) -> Vector2i:
	for i in range(word.size()):
		_print_char(coords, word[i], source_id)
		coords.x += 1
	return coords

func _print_char(coords: Vector2i, character: int, source_id: int) -> void:
	tile_map_layer.set_cell(coords + offset, source_id, Vector2i(character & _char_mod, character >> _char_shift))
