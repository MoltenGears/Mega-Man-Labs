extends "common.gd"

export(int) var jump_speed := -285
export(int) var horizontal_speed := 70

func _enter() -> void:
    animated_sprite.play("jump")
    velocity.y = jump_speed

func _update(delta: float) -> void:
    velocity.x = owner.get_facing_direction().x * horizontal_speed
    velocity.y = clamp(velocity.y + Constants.GRAVITY, -Constants.FALL_SPEED_MAX, Constants.FALL_SPEED_MAX)
    owner.move_and_slide(velocity, Constants.FLOOR_NORMAL)

    if owner.is_on_floor():
        emit_signal("finished", "idle")
