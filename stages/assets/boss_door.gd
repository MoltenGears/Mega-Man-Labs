extends Node2D

var _camera_transition: CameraTransition
var _player: Player
var _reset_lock := true
var _is_open := false

signal closed()

func _ready() -> void:
    add_to_group("BossDoors")

func on_restarted() -> void:
    if _reset_lock:
        unlock_door()

func on_checkpoint_reached() -> void:
    if is_locked():
        _reset_lock = false

func on_transition_entered(transition: Area2D) -> void:
    if transition is CameraTransition:
        _camera_transition = transition as CameraTransition
        _camera_transition.monitoring = false

func on_entered(body: PhysicsBody2D) -> void:
    if not body is Player or is_locked():
        return
    _player = body as Player
    open()

func on_exited(body: PhysicsBody2D) -> void:
    if not body is Player or is_locked():
        return
    _player = null
    close()
    lock_door()

func open() -> void:
    get_tree().paused = true
    $"Sprite/AnimationPlayer".play("open_close")
    $AudioStreamPlayer.play()
    _is_open = true

func close() -> void:
    emit_signal("closed")
    $"Sprite/AnimationPlayer".play_backwards("open_close")
    $AudioStreamPlayer.play()
    _is_open = false

func on_animation_finished(anim_name: String) -> void:
    if _player and _is_open:
        _camera_transition.on_body_entered(_player)

func lock_door() -> void:
    $StaticBody2D.set_collision_layer_bit(0, true)

func unlock_door() -> void:
    $StaticBody2D.set_collision_layer_bit(0, false)

func is_locked() -> bool:
    return $StaticBody2D.get_collision_layer_bit(0)
