extends State

const VELOCITY: int = 16

var _rotating_left: bool

onready var _animations: AnimationPlayer = $"../../EnemyAnimations"
onready var _inputs: InputHandler = $"../../Inputs"

func _enter() -> void:
    _animations.play("rotate")
    _rotating_left = true

func _update(delta: float) -> void:
    var direction: Vector2 = _inputs.get_input_direction()
    
    if direction.x >= 0 and _rotating_left:
        _animations.play_backwards("rotate")
        _rotating_left = false
    elif direction.x < 0 and not _rotating_left:
        _animations.play("rotate")
        _rotating_left = true
    
    owner.move_and_slide(direction * VELOCITY, Vector2.UP)
