extends "common.gd"

func _enter() -> void:
    get_parent().locked = true
    animation_player.play("spawn")
    owner.is_invincible = true

func _handle_command(command: String) -> void:
    pass

func _on_animation_finished(anim_name: String) -> void:
    if anim_name == "spawn":
        owner.is_dead = false
        owner.is_invincible = false
        owner.is_controllable = true
        get_parent().locked = false
        emit_signal("finished", "idle")
