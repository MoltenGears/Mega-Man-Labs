extends KinematicBody2D

export(bool) var persistent := false
export(bool) var respawns_on_restart := false

var _velocity: Vector2
var _start_pos: Vector2

func _ready() -> void:
    _start_pos = global_position
    $PreciseVisibilityNotifier2D.enabled = !persistent

    if respawns_on_restart:
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

func on_camera_exited() -> void:
    queue_free()

func _physics_process(delta: float) -> void:
    _velocity = move_and_slide(_velocity, Constants.FLOOR_NORMAL)
    _velocity.y = clamp(
        _velocity.y + Constants.GRAVITY,
        -Constants.FALL_SPEED_MAX,
        Constants.FALL_SPEED_MAX)

func on_body_entered(body: PhysicsBody2D) -> void:
    if body is Player:
        _on_picked_up_effect(body as Player)
        visible = false
        $Area2D.set_deferred("monitoring", false)

        if not respawns_on_restart:
            queue_free()

# Virutal method. Override in actual item for desired effect.
func _on_picked_up_effect(body: Player) -> void:
    pass
