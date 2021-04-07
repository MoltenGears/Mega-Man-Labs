extends KinematicBody2D

var direction: Vector2
    
func _ready() -> void:
    if not $PreciseVisibilityNotifier2D.is_on_screen():
        queue_free()
    $ShootSFX.play()

func _physics_process(delta: float) -> void:
    move_and_collide(direction.normalized() * Global.get_projectile_speed() * delta)

func reflect() -> void:
    $ReflectSFX.play()
    direction = Vector2(-direction.x, -1)
    set_collision_layer_bit(3, false)

func on_camera_exited() -> void:
    queue_free()
