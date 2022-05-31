extends Node2D

var locked := false
var _section_1: Section
var _section_2: Section
var _player: Player
var _reset_lock := true
var _players_ready_count := 0

signal closed()

func _ready() -> void:
    add_to_group("BossDoors")

func on_restarted() -> void:
    _players_ready_count = 0
    if _reset_lock:
        locked = false

func on_checkpoint_reached() -> void:
    if locked:
        _reset_lock = false

func on_section_entered(section: Node2D) -> void:
    if section.owner is Section:
        if not _section_1:
            _section_1 = section.owner as Section
        elif not _section_2:
            _section_2 = section.owner as Section

func on_entered(body: PhysicsBody2D) -> void:
    if not body is Player or locked:
        return
    _player = body as Player
    _increment_players_ready_count()
    if _all_players_ready():
        open_door()
        open()

func on_exited(body: PhysicsBody2D) -> void:
    if not body is Player or locked:
        return
    _player = null
    _decrement_players_ready_count()
    if is_door_open():
        close()
        locked = true

func open() -> void:
    get_tree().paused = true
    $"Sprite/AnimationPlayer".play("open_close")
    $AudioStreamPlayer.play()
    open_door()

func close() -> void:
    emit_signal("closed")
    $"Sprite/AnimationPlayer".play_backwards("open_close")
    $AudioStreamPlayer.play()
    close_door()

func on_animation_finished(anim_name: String) -> void:
    if _player and is_door_open():
        for p in Global.get_players().values():
            if not p.is_dead:
                if _section_1.active:
                    _section_2.on_body_entered(p)
                else:
                    _section_1.on_body_entered(p)

func open_door() -> void:
    $StaticBody2D.set_collision_layer_bit(0, false)

func close_door() -> void:
    $StaticBody2D.set_collision_layer_bit(0, true)

func is_door_open() -> bool:
    return !$StaticBody2D.get_collision_layer_bit(0)

func _reset_players_ready_count() -> void:
    _players_ready_count = 0

func _increment_players_ready_count() -> void:
    _players_ready_count = clamp(_players_ready_count + 1, 0, Global.players_alive_count)

func _decrement_players_ready_count() -> void:
    _players_ready_count = clamp(_players_ready_count - 1, 0, Global.players_alive_count)

func _all_players_ready() -> bool:
    if _players_ready_count > Global.players_alive_count:
        _players_ready_count = Global.players_alive_count
    return _players_ready_count == Global.players_alive_count
