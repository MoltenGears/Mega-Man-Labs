extends "common.gd"

const WALK_SPEED: float = 61.9
const DISTANCE_MIN: float = 0.5
const GRAVITY: float = 15.0
const FALL_SPEED_MAX: float = 420.0

var distance_traveled: Array
var last_pos: Vector2

func _enter() -> void:
    animated_sprite.play("idle")
    distance_traveled = [1, 1, 1]
    last_pos = owner.global_position

func _update(delta: float) -> void:
    if owner.is_on_floor():
        animated_sprite.play("idle")

    ._update(delta)
    velocity.x = owner.get_facing_direction().x * WALK_SPEED
    velocity.y = clamp(velocity.y + GRAVITY, -FALL_SPEED_MAX, FALL_SPEED_MAX)
    owner.move_and_slide(velocity, Constants.FLOOR_NORMAL)

    distance_traveled.push_front(owner.global_position.distance_to(last_pos))
    distance_traveled.pop_back()
    last_pos = owner.global_position
    
    if distance_traveled[0] + distance_traveled[1] + distance_traveled[2] < DISTANCE_MIN:
        owner.set_facing_direction(-owner.get_facing_direction())
