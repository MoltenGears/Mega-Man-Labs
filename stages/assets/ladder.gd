tool
extends StaticBody2D

const TILE_SIZE := 16

export(int) var size_in_tiles := 3 setget _set_size

var _players: Array = []

func _ready() -> void:
    set_physics_process(false)
    $Ladder.connect("body_entered", self, "_on_body_entered")
    $Ladder.connect("body_exited", self, "_on_body_exited")

func _on_body_entered(body: PhysicsBody2D) -> void:
    if body is Player:
        _players.append(body as Player)
        _players.back().ladder = self
        set_physics_process(true)

func _on_body_exited(body: PhysicsBody2D) -> void:
    var index: int = _players.find(body)
    if index == -1:
        return

    if _is_above_ladder(_players[index]) and _players[index].is_climbing:
        _players[index].move_and_collide(Vector2(0, -_get_distance_to_ladder_top(_players[index]) - 1))
    
    # _players[index].get_node("Sprite").offset.y = 0
    # _players[index].get_node("CollisionShape2D").shape.extents.y = 12
    _players[index].stop_climb()
    _players[index].ladder = null
    _set_collidable(_players[index], true)
    _players.remove(index)

    if _players.empty():
        set_physics_process(false)

func _physics_process(delta: float) -> void:
    for player in _players:
        if not player.is_climbing and not player.is_sliding and \
                player.get_node("StateMachine").current_state != player.get_node("StateMachine/Stagger") and \
                (player.get_node("Inputs").is_action_pressed(InputHandler.Action.UP) and not _is_above_ladder(player) or \
                player.get_node("Inputs").is_action_pressed(InputHandler.Action.DOWN) and _is_above_ladder(player)):
            var distance_to_center = $"Ladder/LadderCollision".global_position - player.global_position
            distance_to_center.y = 0
            player.climb(distance_to_center)
            _set_collidable(player, false)

func is_exiting_ladder(player: Player) -> bool:
    if player in _players:
        return _get_distance_to_ladder_top(player) < player.get_node("CollisionShape2D").shape.extents.y + 2
    else:
        return false

func _set_collidable(player: Player, value: bool) -> void:
    player.set_collision_mask_bit(6, value)

func _is_above_ladder(player: Player) -> bool:
    return _get_distance_to_ladder_top(player) < 0

func _get_distance_to_ladder_top(player: Player) -> float:
    return player.get_node("CollisionShape2D").global_position.y - \
        $CollisionSegment.global_position.y + \
        player.get_node("CollisionShape2D").shape.extents.y

func _set_size(value: int) -> void:
    if not has_node("Ladder"):
        return
    
    size_in_tiles = value
    $"Ladder/LadderCollision".shape.extents.y = size_in_tiles * TILE_SIZE / 2
    $"Ladder/LadderCollision".position.y = size_in_tiles * TILE_SIZE / 2 - 1
