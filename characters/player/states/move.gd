extends "on_ground.gd"

const STALL_FRAME_COUNT: int = 4
const SHOOT_FRAME_COUNT_MAX: int = 19

var _direction: Vector2
var _velocity: Vector2
var _frame_count: int
var _shoot_frame_count: int
var _stall_frame_count: int
var _current_animation_pos: float

func _enter() -> void:
    _velocity = Vector2()
    _frame_count = -1
    _shoot_frame_count = SHOOT_FRAME_COUNT_MAX
    _stall_frame_count = STALL_FRAME_COUNT if owner.is_still else 0
    mega_buster.position = Vector2(17, 0)

func _exit() -> void:
    owner.is_still = false

func _handle_command(command: String) -> void:
    ._handle_command(command)
    
    if command == "shoot":
        _shoot_frame_count = -1
        if animation_player.current_animation != "move_shoot":
            _current_animation_pos = animation_player.current_animation_position
            animation_player.play("move_shoot")
            animation_player.seek(_current_animation_pos, true)
        shoot()
    
func _update(delta: float) -> void:
    _frame_count += 1
    _shoot_frame_count += 1
    _direction = get_input_direction()
    update_sprite_direction(_direction)

    if _direction.x == 0:
        emit_signal("finished", "idle")
        return
    elif _frame_count == 0:
        animation_player.play("ramp")
    
    _velocity.y += owner.gravity

    if _frame_count < 1 or _frame_count > _stall_frame_count:
        _velocity.x = Constants.WALK_SPEED * _direction.x
    else:
        _velocity.x = 0

    _velocity = owner.move_and_slide(_velocity, Constants.FLOOR_NORMAL)

    if _frame_count > _stall_frame_count and _shoot_frame_count > SHOOT_FRAME_COUNT_MAX and \
            animation_player.current_animation != "move":
        _current_animation_pos = animation_player.current_animation_position
        animation_player.play("move")
        animation_player.seek(_current_animation_pos, true)

    if not owner.is_on_floor():
        emit_signal("finished", "jump")
