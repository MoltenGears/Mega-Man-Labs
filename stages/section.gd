tool
extends Node2D

# Area that defines a section of the stage. Triggers a camera transition when player enters.
class_name Section

export(bool) var sealed setget _seal
export(bool) var seal_previous_section # Is consumed when one previous section is sealed.
export(int, 256, 3840, 16) var width := 384 setget _set_width
export(int, 224, 2400, 16) var height := 240 setget _set_height

var limit_left: float
var limit_top: float
var limit_right: float
var limit_bottom: float

var transition_dir: Vector2

var active: bool

var _remove_seal_on_restart: bool = true
var _can_seal_previous: bool
var _players_ready_count := 0

signal transition_entered(transition)

func _ready() -> void:
    if Engine.editor_hint:
        return

    limit_left = global_position.x
    limit_top = global_position.y
    limit_right = global_position.x + $"Area2D/CollisionShape2D".shape.extents.x * 2
    limit_bottom = global_position.y + $"Area2D/CollisionShape2D".shape.extents.y * 2

    _seal(sealed)
    _can_seal_previous = seal_previous_section

    $Area2D.connect("body_entered", self, "on_body_entered")
    $Area2D.connect("body_exited", self, "_on_body_exited")

func on_body_entered(body: Node) -> void:
    if not body is Player or active:
        return

    # print(body.name, " entered ", name, " at ", to_local(body.global_position).round())

    var cam: Camera2D = Global.get_current_stage().get_current_camera()
    if not cam.active_section or Global.get_current_stage().restarting:
        cam.active_section = self
        return
    else:
        _update_direction(cam.active_section)

    if transition_dir == Vector2.ZERO:
        return

    if transition_dir == Vector2.UP and not body.is_climbing:
        return

    _increment_players_ready_count()
    if not _all_players_ready():
        return

    emit_signal("transition_entered", self)

func _on_body_exited(body: Node) -> void:
    if not body is Player:
        return

    if not active:
        _decrement_players_ready_count()

    # print(body.name, " exited ", name, " at ", to_local(body.global_position).round())

func on_restarted() -> void:
    _reset_players_ready_count()
    if _can_seal_previous:
        seal_previous_section = true
    if sealed and _remove_seal_on_restart:
        _seal(false)

func on_checkpoint_reached() -> void:
    if sealed:
        _remove_seal_on_restart = false

func _seal(value: bool) -> void:
    sealed = value
    $BlockingWall.set_collision_mask_bit(1, sealed)
    $BlockingWall.set_collision_layer_bit(7, sealed)
    $Area2D.set_collision_mask_bit(1, !sealed)

func _update_direction(previous_section: Section) -> void:
    transition_dir = Vector2.ZERO
    var is_vertical: bool = true

    if limit_left >= previous_section.limit_right or limit_right <= previous_section.limit_left:
        is_vertical = false

    if is_vertical:
        if global_position.y > previous_section.global_position.y:
            transition_dir = Vector2.DOWN
            # print("Transition Direction: DOWN")
        else:
            transition_dir = Vector2.UP
            # print("Transition Direction: UP")
    else:
        if global_position.x > previous_section.global_position.x:
            transition_dir = Vector2.RIGHT
            # print("Transition Direction: RIGHT")
        else:
            transition_dir = Vector2.LEFT
            # print("Transition Direction: LEFT")

func _set_width(value: int) -> void:
    width = value
    _update_size()

func _set_height(value: int) -> void:
    height = value
    _update_size()

func _update_size() -> void:
    var extents := Vector2(width / 2, height / 2)
    $"Area2D/CollisionShape2D".shape.extents = extents
    $"Area2D/CollisionShape2D".position = extents
    $"BlockingWall/CollisionShape2D".shape.extents = extents
    $"BlockingWall/CollisionShape2D".position = extents
    $DebugRect.update()

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

# Returns global position of section center.
func get_section_center() -> Vector2:
    return Vector2(limit_left + limit_right / 2, limit_top + limit_bottom / 2)
