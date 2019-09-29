tool
extends StaticBody2D

const TILE_SIZE := 16

export(int) var size_in_tiles := 3 setget _set_size

var _player: Player

func _ready() -> void:
    set_physics_process(false)
    $Ladder.connect("body_entered", self, "_on_body_entered")
    $Ladder.connect("body_exited", self, "_on_body_exited")

func _on_body_entered(body: PhysicsBody2D) -> void:
    if body is Player:
        _player = body as Player
        _player.ladder = self
        set_physics_process(true)

func _on_body_exited(body: PhysicsBody2D) -> void:
    if not _player:
        return

    if _is_above_ladder() and _player.is_climbing:
        _player.move_and_collide(Vector2(0, -_get_distance_to_ladder_top() - 1))
    
    # _player.get_node("Sprite").offset.y = 0
    # _player.get_node("CollisionShape2D").shape.extents.y = 12
    _player.stop_climb()
    set_physics_process(false)
    _player.ladder = null
    _player = null
    _set_collidable(true)

func _physics_process(delta: float) -> void:
    if not _player.is_climbing and not _player.is_sliding and \
            _player.get_node("StateMachine").current_state != _player.get_node("StateMachine/Stagger") and \
            (Input.is_action_pressed("action_up") and not _is_above_ladder() or \
            Input.is_action_pressed("action_down") and _is_above_ladder()):
        var distance_to_center = $"Ladder/LadderCollision".global_position - _player.global_position
        distance_to_center.y = 0
        _player.climb(distance_to_center)
        _set_collidable(false)

func is_exiting_ladder() -> bool:
    return _get_distance_to_ladder_top() < _player.get_node("CollisionShape2D").shape.extents.y + 2

func _set_collidable(value: bool) -> void:
    set_collision_layer_bit(0, value)
    set_collision_mask_bit(1, value)

func _is_above_ladder() -> bool:
    if _player:
        return _get_distance_to_ladder_top() < 0
    else:
        return false

func _get_distance_to_ladder_top() -> float:
    return _player.get_node("CollisionShape2D").global_position.y - \
    $CollisionSegment.global_position.y + \
    _player.get_node("CollisionShape2D").shape.extents.y

func _set_size(value: int) -> void:
    if not has_node("Ladder"):
        return
    
    size_in_tiles = value
    $"Ladder/LadderCollision".shape.extents.y = size_in_tiles * TILE_SIZE / 2
    $"Ladder/LadderCollision".position.y = size_in_tiles * TILE_SIZE / 2 - 1
