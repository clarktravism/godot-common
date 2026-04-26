extends Node
class_name TileMapCursor

@export var tile_map_writer: TileMapWriter
@export var offset: Vector2i = Vector2i(0, 0)
@export var text_width: int = 24
# number of characters past the word wrap before it hyphenates
@export var hyphen_min: int = 8

var _cursor_coords: Vector2i
var _word: PackedByteArray

func _ready() -> void:
	_word = PackedByteArray()
	_word.resize(32)
	_word.clear()

func reset(clear_tilemap: bool = true) -> void:
	_cursor_coords = Vector2i(0, 0)
	if clear_tilemap:
		tile_map_writer.clear()

func set_cursor(value: Vector2i) -> void:
	_cursor_coords = value

func get_cursor() -> Vector2i:
	return _cursor_coords

# writes a new line, with a new line at the end
func write_line(text: String, source_index: int = 0) -> void:
	var coords = _print_text(_cursor_coords, text, source_index)
	_cursor_coords = Vector2i(0, coords.y+1)

func write(text: String, source_index: int = 0) -> void:
	_cursor_coords = _print_text(_cursor_coords, text, source_index)

func new_line(lines: int = 1) -> void:
	_cursor_coords = Vector2i(0, _cursor_coords.y+lines)

func _print_text(coords: Vector2i, text: String, source_index: int = 0) -> Vector2i:
	var source_id = tile_map_writer.tile_set.get_source_id(source_index)
	var buffer = text.to_ascii_buffer()
	_word.clear()
	for i in range(buffer.size()):
		if buffer[i] == 13: continue
		#flush word
		if buffer[i] == 32 || buffer[i] == 10:
			_word.append(32)
			coords = _print_word(coords, source_id)
			_word.clear()
			# new line
			if buffer[i] == 10:
				coords.x = 0
				coords.y += 1
			continue
		#word wrap
		if i+1 != buffer.size() && buffer[i+1] != 32 && buffer[i+1] != 10:
			if coords.x + _word.size() > text_width:
				if _word.size() < hyphen_min:
					coords.x = 0
					coords.y += 1
				else: #hyphenation
					_word.append(45)
					coords = _print_word(coords, source_id)
					_word.clear()
					coords.x = 0
					coords.y += 1
		#copy character to word
		_word.append(buffer[i])
	# final word
	coords = _print_word(coords, source_id)
	return coords

func _print_word(coords: Vector2i, source_id: int) -> Vector2i:
	tile_map_writer.write_bytes(coords+offset, _word, source_id)
	coords.x += _word.size()
	return coords
