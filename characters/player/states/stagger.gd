extends "common.gd"

const KNOCKBACK_VELOCITY: float = 20.0

var velocity: Vector2

onready var _ray_cast: RayCast2D = get_node("../../CollisionShape2D/RayCast2D")
onready var _animation_invincibility: AnimationPlayer = get_node("../../AnimationInvincibility")

func _enter() -> void:
    animation_player.play("stagger")
    _animation_invincibility.play("invincibility")
    velocity = Vector2()

func _update(delta: float) -> void:
    velocity.x = -owner.get_facing_direction().x * KNOCKBACK_VELOCITY
    velocity.y = clamp(velocity.y + owner.gravity, -Constants.FALL_SPEED_MAX, Constants.FALL_SPEED_MAX)
    velocity = owner.move_and_slide(velocity, Constants.FLOOR_NORMAL)

func _handle_command(command: String) -> void:
    pass

func _on_animation_finished(anim_name: String) -> void:
    if anim_name == "stagger":
        _ray_cast.force_raycast_update()
        if _ray_cast.is_colliding():
            emit_signal("finished", "slide")
        elif owner.is_on_floor():
            emit_signal("finished", "idle")
        else:
            emit_signal("finished", "jump")
