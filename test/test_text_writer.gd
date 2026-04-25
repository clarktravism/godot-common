extends Node2D

@onready var tile_map_writer: TileMapWriter = $TileMapWriter

func _ready() -> void:
	tile_map_writer.write_line("Hello World!", 14)
	tile_map_writer.write_line("Hello World!", 14)
	tile_map_writer.write("Hello World!", 14)
	tile_map_writer.write_line("I want to stress test the word wrap", 14)
	tile_map_writer.write_line("Hello World!", 14)
	tile_map_writer.write_line("I want to stress test the word wrap", 14)
	tile_map_writer.write_line("Hello World!", 14)
