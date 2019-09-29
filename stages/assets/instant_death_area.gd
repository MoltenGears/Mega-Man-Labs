extends Area2D

var _player: Player

func _ready() -> void:
    set_physics_process(false)
    connect("body_entered", self, "_on_body_entered")
    connect("body_exited", self, "_on_body_exited")

func _on_body_entered(body: PhysicsBody2D) -> void:
    if body is Player:
        _player = body as Player
        set_physics_process(true)

func _on_body_exited(body: PhysicsBody2D) -> void:
    if body is Player:
        set_physics_process(false)
        _player = null

func _physics_process(delta: float) -> void:
    _player.on_hit(99)        
