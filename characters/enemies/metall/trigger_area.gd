extends Area2D

var player: Player
var is_shot_ready := true

onready var _timer: Timer = $"../Timer"

func on_body_entered(body: PhysicsBody2D) -> void:
    if body is Player:
        player = body as Player
        if is_shot_ready:
            is_shot_ready = false
            _timer.call_deferred("emit_signal", "timeout")
            _timer.start()    # Reset timer

func on_body_exited(body: PhysicsBody2D) -> void:
    if body is Player:
        player = null
