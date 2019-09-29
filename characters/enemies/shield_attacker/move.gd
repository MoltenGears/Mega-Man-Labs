extends State

const VELOCITY: int = 100

var _distance_traveled: float

func _enter() -> void:
    $"../../EnemyAnimations".play("move")
    _distance_traveled = 0

func _update(delta: float) -> void:
    _distance_traveled += VELOCITY * delta
    owner.position += owner.get_facing_direction() * VELOCITY * delta

    if _distance_traveled > owner.max_distance:
        emit_signal("finished", "turn")
