extends "jump.gd"

func _enter() -> void:
    animation_player.play("jump_shoot")
    mega_buster.position = Vector2(17, -4)
    velocity = _velocity_init
    _velocity_init = Vector2()
    shoot()

func _handle_command(command: String) -> void:
    if command == "jump_stop" and velocity.y < 0:
        velocity.y = 0
        
    if command == "shoot":
        animation_player.play("jump_shoot")
        shoot()
    
    if command.begins_with("weapon_"):
        weapons.change_weapon(command)

func _on_animation_finished(anim_name: String) -> void:
    emit_signal("finished", "jump")
