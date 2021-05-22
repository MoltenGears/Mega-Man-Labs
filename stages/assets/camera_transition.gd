tool
extends Area2D

# Area that triggers a camera transition when player enters.
class_name CameraTransition

const WIDTH: int = 4

export(bool) var is_one_way := false
export(bool) var is_rotated := false setget _set_rotation
export(bool) var is_death_pit := false
export(int) var size := 1 setget set_extents
export(Vector2) var base_size := Vector2(Constants.WIDTH, Constants.HEIGHT) setget set_base_size

var is_boss_door_transition := false
var _has_enough_space_to_transition := true
var _reset_one_way := true
var _one_way_locked := false
var _is_open_ceiling := false
var _players_ready_count := 0

signal transition_entered(dir, transition)

func _ready() -> void:
    connect("body_entered", self, "on_body_entered")
    connect("body_exited", self, "on_body_exited")
    set_extents(size)

func on_restarted() -> void:
    _reset_players_ready_count()
    if is_one_way and _reset_one_way:
        _one_way_locked = false
        turn_off_wall()

func on_checkpoint_reached() -> void:
    if is_one_way and is_wall_on():
        _reset_one_way = false

func on_body_entered(body: PhysicsBody2D, test_only: bool = false) -> bool:
    if not body is Player:
        return false
    if is_death_pit and is_rotated:
        return false
    if _is_open_ceiling and not body.is_climbing:
        return false

    var dir: Vector2 = _get_direction(body)
    if dir == Vector2.UP and not body.is_climbing:
        _is_open_ceiling = true
        # print_debug("Set %s to open ceiling." % name)
        return false

    # Prevent breaking the camera transition with slides in opposite direction.
    if body.is_sliding and body.get_facing_direction() == -dir:
        return false

    # Important to do before checking for enough empty space.
    _increment_players_ready_count()
    if not is_boss_door_transition and not _all_players_ready():
        turn_on_wall()
        return false

    if _one_way_locked:
        return false
    else:
        turn_off_wall()

    # Check for enough empty space after transition.
    if not body.check_for_space(dir, $CollisionShape2D.shape.extents):
        turn_on_wall()
        _has_enough_space_to_transition = false
        return false

    _is_open_ceiling = false

    if test_only:
        return true

    emit_signal("transition_entered", dir, self)
    if is_one_way:
        _one_way_locked = true
        turn_on_wall()

    return true

func on_body_exited(body: PhysicsBody2D) -> void:
    _decrement_players_ready_count()
    if not _has_enough_space_to_transition:
        _has_enough_space_to_transition = true
        if not _one_way_locked:
            turn_off_wall()

func turn_on_wall() -> void:
    $StaticBody2D.set_collision_mask_bit(1, true)

func turn_off_wall() -> void:
    $StaticBody2D.set_collision_mask_bit(1, false)

func is_wall_on() -> bool:
    return $StaticBody2D.get_collision_mask_bit(1)

func set_extents(value: int) -> void:
    # Checks are necessary, otherwise this method causes errors
    # when called before nodes entered the scene tree.
    if not has_node("CollisionShape2D") or not has_node("StaticBody2D/CollisionShape2D"):
        return
    size = value
    if is_rotated:
        $CollisionShape2D.shape.extents = Vector2(base_size.x / 2 * size, WIDTH)
        $"StaticBody2D/CollisionShape2D".shape.extents = Vector2(
            $CollisionShape2D.shape.extents.x, 1)
    else:
        $CollisionShape2D.shape.extents = Vector2(WIDTH, base_size.y / 2 * size)
        $"StaticBody2D/CollisionShape2D".shape.extents = Vector2(
            1, $CollisionShape2D.shape.extents.y)

func set_base_size(value: Vector2) -> void:
    base_size = value
    set_extents(size)

func _reset_players_ready_count() -> void:
    _players_ready_count = 0

func _increment_players_ready_count() -> void:
    _players_ready_count = clamp(_players_ready_count + 1, 0, Global.players_alive_count)

func _decrement_players_ready_count() -> void:
    _players_ready_count = clamp(_players_ready_count - 1, 0, Global.players_alive_count)

func _set_rotation(value: bool) -> void:
    is_rotated = value
    set_extents(size)

func _get_direction(body: PhysicsBody2D) -> Vector2:
    if $CollisionShape2D.shape.extents.x > $CollisionShape2D.shape.extents.y:
        return Vector2(0, sign((global_position - body.global_position).y))
    else:
        return Vector2(sign((global_position - body.global_position).x), 0)

func _all_players_ready() -> bool:
    if _players_ready_count > Global.players_alive_count:
        _players_ready_count = Global.players_alive_count
    return _players_ready_count == Global.players_alive_count
