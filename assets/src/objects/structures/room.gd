extends Node2D

var tile_data : Array

# Pointer------------
var tile : TileMap

# # = 벽타일, . = 바닥타일
const WALL_TILE_TERRAIN = 1
const FLOOR_TILE_TERRAIN = 0

func _ready():
	tile = $tile
	set_tiles()
	
func _process(delta):
	for area in $room.get_overlapping_areas():
		if area.name == "player" and area.get_parent() is Player:
			Info.room_in_player_pos = global_position


	
func set_tiles():
	for y in tile_data.size():
		for x in tile_data[y].length():
			var char = tile_data[y][x]
			var tile_terrain_num = -1

			if char == "#":
				tile.set_cells_terrain_connect(2, [Vector2i(x, y)], 0, WALL_TILE_TERRAIN)
			elif char == ".":
				tile.set_cells_terrain_connect(2, [Vector2i(x, y)], 0, FLOOR_TILE_TERRAIN)
			elif char == "@":
				tile.set_cell(1, Vector2i(x, y), 0, Vector2i(2, 12))
				tile.set_cells_terrain_connect(2, [Vector2i(x, y)], 0, FLOOR_TILE_TERRAIN)


func _on_room_area_entered(area):
	if area.name == "player":
		#Info.room_in_player_pos = global_position
		pass
