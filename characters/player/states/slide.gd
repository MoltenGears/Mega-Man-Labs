extends "on_ground.gd"

const LOCKED_FRAME_COUNT: int = 8
const SLIDE_SPEED: float = 150.0
const SLIDE_FRAME_COUNT: int = 25

onready var _collision_shape: CollisionShape2D = get_node("../../CollisionShape2D")
onready var _ray_cast: RayCast2D = get_node("../../CollisionShape2D/RayCast2D")
onready var _slide_dust: Sprite = get_node("../../SpriteDust")
onready var _slide_dust_anim: AnimationPlayer = get_node("../../SpriteDust/AnimationDust")

var _frame_count: int
var _can_exit: bool
var velocity: Vector2

func _enter() -> void:
    owner.is_sliding = true
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
    if command == "jump" and _can_exit and \
            _frame_count >= LOCKED_FRAME_COUNT:
        emit_signal("finished", "jump")

func _exit() -> void:
    owner.is_sliding = false
    _ray_cast.enabled = false
    _collision_shape.shape.extents.x /= 2
    _collision_shape.shape.extents.y *= 2
    _collision_shape.position.y -= 6

func _update(delta: float) -> void:
    velocity.y += owner.gravity
    velocity.x = SLIDE_SPEED * owner.get_facing_direction().x
    velocity = owner.move_and_slide(velocity, Constants.FLOOR_NORMAL)

    _can_exit = !_ray_cast.is_colliding()
    
    if _frame_count > SLIDE_FRAME_COUNT and _can_exit:
        emit_signal("finished", "idle")

    var input_direction: Vector2 = get_input_direction()
    if _frame_count > LOCKED_FRAME_COUNT and _can_exit and \
            input_direction.x == -owner.get_facing_direction().x:
        emit_signal("finished", "move")

    if not _can_exit:
        update_sprite_direction(input_direction)
    
    _frame_count += 1

    if not owner.is_on_floor() and _can_exit:
        emit_signal("finished", "jump")
