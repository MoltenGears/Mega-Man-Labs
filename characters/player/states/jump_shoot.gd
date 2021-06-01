extends "jump.gd"

export(Vector2) var buster_position := Vector2(17, -4)

func _enter() -> void:
    animation_player.play(
        "jump_shoot_alt" if weapons.current_state.use_alt_anim else "jump_shoot")
    mega_buster.position = buster_position
    velocity = _velocity_init
    _velocity_init = Vector2()
    shoot()

func _handle_command(command: String) -> void:
    if command == "jump_stop" and velocity.y < 0:
        velocity.y = 0
        
    if command == "shoot":
        animation_player.play(
            "jump_shoot_alt" if weapons.current_state.use_alt_anim else "jump_shoot")
        shoot()
    
    if command.begins_with("weapon_"):
        weapons.change_weapon(command)

func _on_animation_finished(anim_name: String) -> void:
    emit_signal("finished", "jump")
