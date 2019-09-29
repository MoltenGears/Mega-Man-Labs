extends KinematicBody2D

var _velocity: Vector2
var _start_pos: Vector2

func _ready() -> void:
    _start_pos = global_position
    add_to_group("SpecialsReset")
    $Area2D.connect("body_entered", self, "on_body_entered")
    _velocity = Vector2()
    
    for child in get_children():
        if "Collision" in child.name:
            $Area2D.add_child(child.duplicate())
    
func on_restarted() -> void:
    _velocity = Vector2()
    global_position = _start_pos
    visible = true
    $Area2D.set_deferred("monitoring", true)

func _physics_process(delta: float) -> void:
    if move_and_collide(_velocity * delta):
        _velocity.y = 0
    else:
        _velocity.y = clamp(_velocity.y + Constants.GRAVITY, -Constants.FALL_SPEED_MAX, Constants.FALL_SPEED_MAX)

func on_body_entered(body: PhysicsBody2D) -> void:
    if body is Player:
        _on_picked_up_effect(body)
        visible = false
        $Area2D.set_deferred("monitoring", false)

func _on_picked_up_effect(body) -> void:
    # TODO: Make function parameter statically typed again when cyclic resource inclusion error gets fixed.
    # Also in function call within on_body_entered above.
    pass
