extends Node2D

@onready var tile_map_cursor: TileMapCursor = $TileMapCursor

func _ready() -> void:
	tile_map_cursor.write_line("Hello World!", 14)
	tile_map_cursor.write_line("Hello World!", 14)
	tile_map_cursor.write("Hello World!", 14)
	tile_map_cursor.write_line("I want to stress test the word wrap", 14)
	tile_map_cursor.write_line("Hello World!", 14)
	tile_map_cursor.write_line("I want to stress test the word wrap", 14)
	tile_map_cursor.write_line("Hello World!", 14)
