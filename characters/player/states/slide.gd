extends "on_ground.gd"

const LOCKED_FRAME_COUNT: int = 8
const SLIDE_SPEED: float = 150.0
const SLIDE_FRAME_COUNT: int = 25

onready var _collision_shape: CollisionShape2D = get_node("../../CollisionShape2D")
onready var _ray_cast: RayCast2D = get_node("../../CollisionShape2D/RayCast2D")
onready var _slide_dust: Sprite = get_node("../../SpriteDust")
onready var _slide_dust_anim: AnimationPlayer = get_node("../../SpriteDust/AnimationDust")

var velocity: Vector2
var _frame_count: int
var _can_exit: bool
var _was_in_front_of_wall: bool
var _cancel_on_next_frame: bool

func _enter() -> void:
    if owner.stopper_ray_cast.is_colliding():
        _was_in_front_of_wall = true
        _cancel_on_next_frame = true
        return
    else:
        _was_in_front_of_wall = false
        _cancel_on_next_frame = false

    owner.is_sliding = true
    owner.buffering_charge = true
    _can_exit = false
    _ray_cast.enabled = true
    animation_player.play("slide")
    _collision_shape.shape.extents.x *= 2
    _collision_shape.shape.extents.y /= 2
    _collision_shape.position.y += 6
    velocity = Vector2()
    _frame_count = 0

    # Slide dust animation
    _slide_dust.set_as_toplevel(true)
    _slide_dust.global_position = owner.global_position
    _slide_dust.flip_h = sprite.flip_h
    _slide_dust_anim.play("dust")

func _handle_command(command: String) -> void:
    if (command == "jump"
        and _can_exit
        and _frame_count >= LOCKED_FRAME_COUNT
        and not Global.is_action_pressed(get_parent().action_down)
        ):
        emit_signal("finished", "jump")

    if command.begins_with("weapon_"):
        weapons.change_weapon(command)

func _exit() -> void:
    if _was_in_front_of_wall:
        return

    owner.is_sliding = false
    _ray_cast.enabled = false
    _collision_shape.shape.extents.x /= 2
    _collision_shape.shape.extents.y *= 2
    _collision_shape.position.y -= 6

func _update(delta: float) -> void:
    if _cancel_on_next_frame:
        emit_signal("finished", "idle")
        return
    
    # Enough empty space above.
    _can_exit = !_ray_cast.is_colliding()

    velocity.y += owner.gravity
    velocity.x = SLIDE_SPEED * owner.get_facing_direction().x
    velocity = owner.move_and_slide(velocity, Constants.FLOOR_NORMAL)

    # Full slide duration passed.
    var input_direction: Vector2 = get_input_direction()
    if _frame_count > SLIDE_FRAME_COUNT and _can_exit:
        if input_direction.x != 0:
            emit_signal("finished", "move")
        else:
            emit_signal("finished", "idle")

    # Cancel slide by pressing the opposite direction.
    if _frame_count > LOCKED_FRAME_COUNT and _can_exit and \
            input_direction.x == -owner.get_facing_direction().x:
        emit_signal("finished", "move")

    if not _can_exit:
        update_sprite_direction(input_direction)
    
    _frame_count += 1

    if not owner.is_on_floor() and _can_exit:
        emit_signal("finished", "jump")

    # Cancel slide on next frame if hitting a wall.
    # Deferring to next frame is required to allow sliding into insta-death hazards.
    if owner.stopper_ray_cast.is_colliding() and _can_exit:
        _cancel_on_next_frame = true
