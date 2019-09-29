extends State

onready var _animations: AnimationPlayer = $"../../AnimationBase"
onready var _animations_special: AnimationPlayer = $"../../AnimationPlayer"

func _enter() -> void:
    $"../../CharacterSprites/AnimatedSprite".visible = true
    get_tree().paused = true
    get_tree().call_group("BossDoors", "lock_door")
    _animations.play("drop_in")
    yield(_animations, "animation_finished")
    _animations_special.play("taunt")
    yield(_animations_special, "animation_finished")
    owner.emit_signal("hit_points_changed", 0)
    owner.life_bar.visible = true
    owner.emit_signal("hit_points_changed", Constants.HIT_POINTS_MAX)
    yield(owner.life_bar, "gradual_update_complete")
    owner.is_invincible = false
    owner.is_restarting = false
    get_tree().paused = false
    owner.emit_signal("boss_ready")
    emit_signal("finished", "idle")
