extends State

const VELOCITY: int = 100

var distance_traveled: float

onready var _inputs: InputHandler = $"../../Inputs"

func _enter() -> void:
    $"../../EnemyAnimations".play("move")
    distance_traveled = 0

func _update(delta: float) -> void:
    distance_traveled += VELOCITY * delta
    owner.move_and_slide(_inputs.get_input_direction() * VELOCITY)

    if _inputs.get_input_direction() == -owner.get_facing_direction():
        emit_signal("finished", "turn")
