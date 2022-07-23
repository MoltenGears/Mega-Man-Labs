extends State

const SHOOT_DELAY: float = 0.3
const Bullet: Resource = preload("EnemyMetallBullet.tscn")

func _enter() -> void:
    owner.is_blocking = false
    $"../../EnemyAnimations".play("shoot")
    yield(owner.start_yield_timer(SHOOT_DELAY), "timeout")

    if owner.is_dead:
        return

    var bullet_pos: Vector2 = $"../../HitBox".global_position
    var bullet: Node = Bullet.instance()
    bullet.position = bullet_pos
    bullet.direction = owner.get_facing_direction()
    Global.get_current_stage().add_child(bullet)

    bullet = Bullet.instance()
    bullet.position = bullet_pos
    bullet.direction = Vector2.DOWN + owner.get_facing_direction()
    Global.get_current_stage().add_child(bullet)

    bullet = Bullet.instance()
    bullet.position = bullet_pos
    bullet.direction = Vector2.UP + owner.get_facing_direction()
    Global.get_current_stage().add_child(bullet)

func _update(delta: float) -> void:
    get_parent().velocity.y = \
        clamp(get_parent().velocity.y + Constants.GRAVITY, -Constants.FALL_SPEED_MAX, Constants.FALL_SPEED_MAX)
    owner.move_and_slide(get_parent().velocity, Vector2.UP)
    if owner.is_on_floor():
        get_parent().velocity = Vector2.ZERO

func _on_animation_finished(anim_name: String) -> void:
    if anim_name == "shoot":
        emit_signal("finished", "idle")
