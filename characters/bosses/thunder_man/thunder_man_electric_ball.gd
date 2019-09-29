extends KinematicBody2D

export(int) var speed := 200
export(int) var damage := 3

var _velocity: Vector2
var direction := Vector2.RIGHT

onready var _area := $Area2D

func _ready() -> void:
    $Timer.connect("timeout", self, "_on_timeout")
    $AnimationPlayer.play("pulse")
    _velocity = Vector2(direction.x * speed, Vector2.DOWN.y * Constants.GRAVITY)

func _physics_process(delta: float) -> void:
    _velocity.y += Constants.GRAVITY
    _velocity = move_and_slide(_velocity)

    for body in _area.get_overlapping_bodies():
        if body is Player:
            body.on_hit(damage)

func _on_timeout() -> void:
    queue_free()
