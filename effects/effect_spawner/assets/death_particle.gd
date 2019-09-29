extends Node2D

var _lifetime: float = -1.0
var direction: Vector2
var velocity: int

func initialize(pos: Vector2, dir: Vector2, velo: int) -> void:
    global_position = pos
    direction = dir
    velocity = velo

func _ready() -> void:
    $VisibilityNotifier2D.connect("screen_exited", self, "_on_screen_exited")
    $AnimationPlayer.play("radiate")
    $Timer.connect("timeout", self, "_on_timeout")
    if _lifetime > 0:
        $Timer.start(_lifetime)

func _physics_process(delta: float) -> void:
    position += direction.normalized() * velocity * delta

func set_lifetime(length: float) -> void:
    _lifetime = length

func _on_screen_exited() -> void:
    queue_free()

func _on_timeout() -> void:
    queue_free()
