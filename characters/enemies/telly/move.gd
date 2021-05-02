extends State

const VELOCITY: int = 16

var _direction: Vector2
var _rotating_left: bool

onready var _animations: AnimationPlayer = $"../../EnemyAnimations"

func _enter() -> void:
    _animations.play("rotate")
    _rotating_left = true

func _update(delta: float) -> void:
    if Global.player:
        _direction = owner.global_position.direction_to(Global.player.global_position)
    
    if _direction.x >= 0 and _rotating_left:
        _animations.play_backwards("rotate")
        _rotating_left = false
    elif _direction.x < 0 and not _rotating_left:
        _animations.play("rotate")
        _rotating_left = true
    
    owner.position += _direction * VELOCITY * delta
