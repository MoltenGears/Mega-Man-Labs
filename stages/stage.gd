tool
extends Node

# Base class for all stages.
class_name Stage

const InstantDeathArea: Resource = preload("res://stages/assets/InstantDeathArea.tscn")
const LadderArea: Resource = preload("res://stages/assets/Ladder.tscn")

# Identifiers for different areas must not be combined for a single tile type.
export(Array, String) var instant_death_identifiers := ["acid", "lava", "spike"]
export(Array, String) var ladder_identifiers := ["ladder"]

# Time constants in seconds.
const START_DELAY: float = 2.0
const DEATH_DELAY: float = 3.0
const BLACK_SCREEN_DELAY: float = 0.5
const FADE_IN_DURATION: float = 0.5
const FADE_OUT_DURATION: float = 1.5
const SPECIALS_RESET_DELAY: float = 0.2
const STAGE_CLEAR_DELAY: float = 6.0

var current_camera: Camera2D setget , get_current_camera
var stage_start_pos: Vector2
var start_pos: Vector2
var start_dir: Vector2
var stage_exited: bool
var player: Player
var players: Dictionary
var restarting: bool

onready var _gui_ready := $"GUI/Ready"
onready var _gui_fade_effects := $"GUI/FadeEffects"
onready var _gui_bar := $"GUI/MarginContainer/LifeEnergyBar"
onready var _gui_weapon_bar := $"GUI/MarginContainer/LifeEnergyBar/WeaponEnergyBar"
onready var _gui_pause := $"GUI/Pause"
onready var _gui_game_over := $"GUI/GameOver"
onready var _gui_weapon_icon_overhead := $"GUI/WeaponIconOverhead"

signal restarted()
signal player_ready()
signal player_died()
signal stage_cleared()

func _init() -> void:
    pause_mode = PAUSE_MODE_STOP
    start_dir = Vector2.RIGHT
    stage_exited = false

func _ready() -> void:
    for child in get_children():
        if child is Player:
            players[child.player_number] = child as Player

    # Set player with smallest player number as main player.
    if not players.empty():
        player = players[players.keys().min()]

    if Engine.is_editor_hint():
        return

    _add_instant_death_areas()
    _add_ladder_areas()

    _connect_signals()
    get_tree().call_group("Enemies", "_replace_with_spawner")
    _restart()

func _get_configuration_warning() -> String:
    if not player:
        return "This stage has no Player. Consider adding a Player node to have a controllable character."
    if not get_current_camera():
        return "This stage has no camera. Consider adding a camera node to have a view on the stage."
    else:
        return ""

# Returns the first Camera2D found in the stage. Should not be used in _ready() callbacks,
# since some nodes' _ready() callbacks are called before the camera is instantiated.
func get_current_camera() -> Camera2D:
    # Search stage nodes.
    if not current_camera:
        for child in get_children():
            if child is Camera2D:
                current_camera = child
                break

    # Search player nodes if not found in stage.
    if not current_camera and player:
        for child in player.get_children():
            if child is Camera2D:
                current_camera = child
                break
    
    if not current_camera:
        printerr("No camera found in current stage.")
    return current_camera

func _restart() -> void:
    restarting = true
    Global.can_toggle_pause = true
    get_tree().paused = true
    get_tree().call_group("Enemies", "queue_free")
    GameState.reset_enemy_count()
    _set_stage_start_pos()

    emit_signal("restarted")
    yield(get_tree().create_timer(0.0 if OS.is_debug_build() else START_DELAY), "timeout")
    emit_signal("player_ready")
    get_tree().paused = false

    # The following delay is also important for the camera to be able to update sections
    # and transition instantly on restart.
    yield(get_tree().create_timer(SPECIALS_RESET_DELAY), "timeout")
    get_tree().call_group("SpecialsReset", "on_restarted")

    restarting = false

func _on_died() -> void:
    for p in players.values():
        if not p.is_dead:
            return

    yield(get_tree().create_timer(DEATH_DELAY), "timeout")
    emit_signal("player_died")

func _on_boss_died() -> void:
    Global.can_toggle_pause = false
    yield(get_tree().create_timer(1.0 if OS.is_debug_build() else STAGE_CLEAR_DELAY), "timeout")
    emit_signal("stage_cleared")

func _on_stage_exited() -> void:
    stage_exited = true
    _gui_fade_effects.fade_out(FADE_OUT_DURATION)

func _on_screen_faded_out() -> void:
    yield(get_tree().create_timer(BLACK_SCREEN_DELAY), "timeout")
    if stage_exited:
        _game_over()
    elif GameState.extra_life_count < 1:
        _game_over()
    else:
        GameState.extra_life_count -= 1
        _restart()

func _game_over() -> void:
    GameState.reset()
    _gui_game_over.show_game_over()

func _set_stage_start_pos() -> void:
    if not player:
        return
    
    if start_pos:
        for p in players.values():
            p.global_position = start_pos
    else:
        start_pos = player.global_position
        stage_start_pos = start_pos

    player.set_facing_direction(start_dir)

func _connect_signals() -> void:
    # Connect various stage signals to children methods.
    for p in players.values():
        _try_connect(self, "restarted", p, "on_restarted")
    _try_connect(self, "restarted", get_current_camera(), "on_restarted")
    _try_connect(self, "restarted", _gui_ready, "on_restarted")
    _try_connect(self, "restarted", _gui_fade_effects, "fade_in", [FADE_IN_DURATION])
    _try_connect(self, "restarted", _gui_bar, "on_restarted")

    if has_node("Sections"):
        for section in $Sections.get_children():
            _try_connect(self, "restarted", section, "on_restarted")
            _try_connect(section, "transition_entered", get_current_camera(), "transition_section")
            for checkpoint in get_tree().get_nodes_in_group("Checkpoints"):
                _try_connect(checkpoint, "checkpoint_reached", section, "on_checkpoint_reached")

    for p in players.values():
        _try_connect(self, "player_ready", p, "on_ready")
    _try_connect(self, "player_ready", _gui_ready, "on_ready")
    _try_connect(self, "player_ready", _gui_pause, "set_can_pause", [true])
    _try_connect(self, "player_died", _gui_fade_effects, "fade_out", [FADE_OUT_DURATION])
    _try_connect(self, "stage_cleared", player, "on_stage_cleared")
    
    # Connect children signals to stage methods.
    for p in players.values():
        _try_connect(p, "died", self, "_on_died")
    _try_connect(_gui_fade_effects, "screen_faded_out", self, "_on_screen_faded_out")
    _try_connect(player, "exited", self, "_on_stage_exited")

    # Connect children signals to other children methods.
    _try_connect(player, "hit_points_changed", _gui_bar, "on_hit_points_changed")
    _try_connect(player, "weapon_energy_changed", _gui_weapon_bar, "on_hit_points_changed")
    _try_connect(player, "weapon_changed", _gui_weapon_bar, "on_weapon_changed")
    _try_connect(player, "weapon_changed", _gui_weapon_icon_overhead, "on_weapon_changed")
    _try_connect(player, "died", _gui_pause, "set_can_pause", [false])
    for p in players.values():
        _try_connect(p, "died", get_current_camera(), "on_died")
        _try_connect(p, "death_freeze_finished", get_current_camera(), "on_death_freeze_finished", [p])

    _try_connect(GameState, "extra_life_count_changed", _gui_pause, "on_extra_life_count_changed")
    _try_connect(GameState, "energy_tank_count_changed", _gui_pause, "on_energy_tank_count_changed")

func _try_connect(source: Object, signal_name: String, target: Object, method_name: String,
        binds: Array = [], flags: int = 0) -> bool:
    var error_msg := "%s: Tried to connect %s signal of source to %s method of target." % [self.name, signal_name, method_name]
    if not source:
        printerr(error_msg, " Source does not exist.")
        return false
    if not target:
        printerr(error_msg, " Target does not exist.")
        return false
    if not target.has_method(method_name):
        printerr(error_msg, " Method on %s does not exist." % target.name)
        return false
    
    if not source.is_connected(signal_name, target, method_name):
        return true if source.connect(signal_name, target, method_name, binds, flags) else false
    else:
        return true

# Iterate all tile types and place instant death areas at their positions
# if their names contain one of the instant death identifiers.
func _add_instant_death_areas() -> void:
    var instant_death_areas_node := Node2D.new()
    instant_death_areas_node.name = "InstantDeathAreas"
    add_child(instant_death_areas_node)
    
    for tile_map in get_tree().get_nodes_in_group("TileMaps"):
        var tile_set = tile_map.tile_set
        for tile_id in tile_set.get_tiles_ids():
            for identifier in instant_death_identifiers:
                if identifier.to_lower() in tile_set.tile_get_name(tile_id).to_lower():
                    for death_cell_pos in tile_map.get_used_cells_by_id(tile_id):
                        var instant_death_area := InstantDeathArea.instance()
                        var instant_death_area_local = \
                                tile_map.map_to_world(death_cell_pos) + Constants.TILE_SIZE / 2
                        var instant_death_area_global = tile_map.to_global(instant_death_area_local)
                        instant_death_area.global_position = instant_death_area_global
                        instant_death_areas_node.add_child(instant_death_area)
                    break

# Iterate all tile types and place ladder areas at their positions
# if their names contain the ladder identifier.
func _add_ladder_areas() -> void:
    var ladder_node := Node2D.new()
    ladder_node.name = "Ladders"
    add_child(ladder_node)

    # Collect ladder tiles from all tile maps first
    # and transform all ladder tiles' grid coordinates to global positions.
    # This is required for correctly building inter-section ladders.
    var ladder_tiles: Array = []
    for tile_map in get_tree().get_nodes_in_group("TileMaps"):
        var tile_set = tile_map.tile_set
        for tile_id in tile_set.get_tiles_ids():
            for identifier in ladder_identifiers:
                if identifier.to_lower() in tile_set.tile_get_name(tile_id).to_lower():
                    var ladder_tiles_coords: Array = tile_map.get_used_cells_by_id(tile_id)
                    for coord in ladder_tiles_coords:
                        var ladder_tiles_local: Vector2 = tile_map.map_to_world(coord)
                        var ladder_tiles_global: Vector2 = tile_map.to_global(ladder_tiles_local)
                        ladder_tiles.append(ladder_tiles_global)
    
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
    var ladder_pos: Vector2 = ladder_tiles[0]
    ladder_pos.x += Constants.TILE_SIZE.x / 2
    var ladder_tile_count := 1

    while ladder_tiles.size() > 1:
        if ladder_tiles[1].y == ladder_tiles[0].y + Constants.TILE_SIZE.y:
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
