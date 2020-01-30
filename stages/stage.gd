tool
extends Node

# Base class for all stages.
class_name Stage

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

onready var _gui_ready := $"GUI/Ready"
onready var _gui_fade_effects := $"GUI/FadeEffects"
onready var _gui_bar := $"GUI/Bar"
onready var _gui_pause := $"GUI/Pause"
onready var _gui_game_over := $"GUI/GameOver"
onready var _music := $Music
onready var _boss := $"Specials/ThunderMan"
onready var _boss_door_left := $"BossDoors/BossDoor02"
onready var _boss_door_right := $"BossDoors/BossDoor03"

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
            player = child as Player
            break
    if Engine.is_editor_hint():
        return

    _connect_signals()
    get_tree().call_group("enemies", "_replace_with_spawner")
    _restart()

func _get_configuration_warning() -> String:
    if not player:
        return "This stage has no Player. Consider adding a Player node to have a controllable character."
    else:
        return ""

# Returns the first Camera2D found in the stage. Should not be used in _ready() callbacks,
# since some nodes' _ready() callbacks are called before the camera is instantiated.
func get_current_camera() -> Camera2D:
    if not current_camera and player:
        for child in player.get_children():
            if child is Camera2D:
                current_camera = child
                break
    
    if not current_camera:
        printerr("No camera found in current stage.")
    return current_camera

func _restart() -> void:
    Global.can_toggle_pause = true
    get_tree().paused = true
    _set_stage_start_pos()

    # Since Godot 3.2 the camera breaks if the 'restarted' signal is emitted
    # at stage load without waiting at least a physics frame.
    yield(get_tree(), "physics_frame")

    emit_signal("restarted")
    yield(get_tree().create_timer(0.0 if OS.is_debug_build() else START_DELAY), "timeout")
    emit_signal("player_ready")
    get_tree().paused = false

    yield(get_tree().create_timer(SPECIALS_RESET_DELAY), "timeout")
    get_tree().call_group("SpecialsReset", "on_restarted")

func _on_died() -> void:
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
        player.global_position = start_pos
    else:
        start_pos = player.global_position
        stage_start_pos = start_pos

    player.set_facing_direction(start_dir)

func _connect_signals() -> void:
    # Connect various stage signals to children methods.
    _try_connect(self, "restarted", player, "on_restarted")
    _try_connect(self, "restarted", _gui_ready, "on_restarted")
    _try_connect(self, "restarted", _gui_fade_effects, "fade_in", [FADE_IN_DURATION])
    _try_connect(self, "restarted", _gui_bar, "on_restarted")
    _try_connect(self, "restarted", _boss, "reset")
    _try_connect(self, "restarted", _music, "on_restarted")

    if has_node("CameraTransitions"):
        for transition in $CameraTransitions.get_children():
            _try_connect(self, "restarted", transition, "on_restarted")
            _try_connect(transition, "transition_entered", get_current_camera(), "transition")
            if has_node("Checkpoints"):
                for checkpoint in $Checkpoints.get_children():
                    _try_connect(checkpoint, "checkpoint_reached", transition, "on_checkpoint_reached")

    if has_node("BossDoors"):
        for boss_door in $BossDoors.get_children():
            _try_connect(self, "restarted", boss_door, "on_restarted")
            if has_node("Checkpoints"):
                for checkpoint in $Checkpoints.get_children():
                    _try_connect(checkpoint, "checkpoint_reached", boss_door, "on_checkpoint_reached")

    _try_connect(self, "player_ready", player, "on_ready")
    _try_connect(self, "player_ready", _gui_ready, "on_ready")
    _try_connect(self, "player_ready", _gui_pause, "set_can_pause", [true])

    _try_connect(self, "player_died", _gui_fade_effects, "fade_out", [FADE_OUT_DURATION])

    _try_connect(self, "stage_cleared", player, "on_stage_cleared")
    
    # Connect children signals to stage methods.
    _try_connect(player, "died", self, "_on_died")
    _try_connect(_gui_fade_effects, "screen_faded_out", self, "_on_screen_faded_out")
    _try_connect(_boss, "boss_died", self, "_on_boss_died")
    _try_connect(player, "exited", self, "_on_stage_exited")

    # Connect children signals to other children methods.
    _try_connect(player, "hit_points_changed", _gui_bar, "on_hit_points_changed")
    _try_connect(player, "died", _music, "on_died")
    _try_connect(_gui_pause, "game_paused", _music, "on_game_paused")
    _try_connect(_gui_pause, "game_resumed", _music, "on_game_resumed")
    _try_connect(_boss, "boss_ready", _music, "on_boss_ready")
    _try_connect(player, "died", _gui_pause, "set_can_pause", [false])
    _try_connect(_boss_door_left, "closed", _music, "on_boss_entered")
    _try_connect(_boss_door_left, "closed", _boss, "on_boss_entered")
    _try_connect(_boss_door_left, "closed", player, "on_boss_entered")
    _try_connect(_boss_door_right, "closed", _music, "on_boss_entered")
    _try_connect(_boss_door_right, "closed", _boss, "on_boss_entered")
    _try_connect(_boss_door_right, "closed", player, "on_boss_entered")
    _try_connect(_boss, "boss_died", player, "on_boss_died")
    _try_connect(_boss, "boss_died", _music, "on_boss_died")
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
