extends State

func _enter() -> void:
    $"../../EnemyAnimations".play("turn")

func _on_animation_finished(anim_name: String) -> void:
    if anim_name == "turn":
        emit_signal("finished", "move")
