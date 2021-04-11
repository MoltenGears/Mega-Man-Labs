extends TileMap

# Tile map with helpers for setting up special tiles like death spikes and ladders.
class_name TileMapExtended

const InstantDeathArea: Resource = preload("res://stages/assets/InstantDeathArea.tscn")
const LadderArea: Resource = preload("res://stages/assets/Ladder.tscn")

# Identifiers for different areas must not be combined for a single tile type.
export(Array, String) var instant_death_identifiers := ["acid", "lava", "spike"]
export(Array, String) var ladder_identifiers := ["ladder"]

func _ready() -> void:
    _add_instant_death_areas()
    _add_ladder_areas()

# Iterate all tile types and place instant death areas at their positions
# if their names contain one of the instant death identifiers.
func _add_instant_death_areas() -> void:
    var instant_death_areas_node := Node.new()
    instant_death_areas_node.name = "InstantDeathAreas"
    add_child(instant_death_areas_node)
    for tile_id in tile_set.get_tiles_ids():
        for identifier in instant_death_identifiers:
            if identifier.to_lower() in tile_set.tile_get_name(tile_id).to_lower():
                for death_cell_pos in get_used_cells_by_id(tile_id):
                    var instant_death_area := InstantDeathArea.instance()
                    instant_death_area.global_position = map_to_world(death_cell_pos) + cell_size / 2
                    instant_death_areas_node.add_child(instant_death_area)
                break

# Iterate all tile types and place ladder areas at their positions
# if their names contain the ladder identifier.
func _add_ladder_areas() -> void:
    var ladder_node := Node.new()
    ladder_node.name = "Ladders"
    add_child(ladder_node)
    for tile_id in tile_set.get_tiles_ids():
        for identifier in ladder_identifiers:
            if identifier.to_lower() in tile_set.tile_get_name(tile_id).to_lower():
                var ladder_tiles := get_used_cells_by_id(tile_id)
                while ladder_tiles.size() > 0:
                    ladder_node.add_child(_construct_ladder(ladder_tiles))

# Returns a ladder node constructed from first set of contiguous ladder tiles
# in array of grid based ladder tile positions. Removes the used ladder
# position elements from the array.
func _construct_ladder(ladder_tiles: Array) -> Node:
    if not ladder_tiles or ladder_tiles.size() == 0:
        printerr("Cannot construct ladder. Ladder tiles array is empty or null.")
        return null

    ladder_tiles.sort_custom(self, "_sort_ladder_tiles")
    var ladder_pos := map_to_world(ladder_tiles[0])
    ladder_pos.x += cell_size.x / 2
    var ladder_tile_count := 1

    while ladder_tiles.size() > 1:
        if ladder_tiles[1].y == ladder_tiles[0].y + 1:
            ladder_tile_count += 1
            ladder_tiles.remove(0)
        else:
            break
    ladder_tiles.remove(0)

    var ladder_area := LadderArea.instance()
    ladder_area.global_position = ladder_pos
    ladder_area.size_in_tiles = ladder_tile_count
    return ladder_area

# Sort tiles in ascending order, where y -> inner and x -> outer.
func _sort_ladder_tiles(item_1: Vector2, item_2: Vector2) -> bool:
    if item_1.x < item_2.x:
        return true
    elif item_1.x > item_2.x:
        return false
    else:
        if item_1.y < item_2.y:
            return true
        else:
            return false
