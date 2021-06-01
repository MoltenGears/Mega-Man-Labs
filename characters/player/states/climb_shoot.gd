extends "climb.gd"

export(Vector2) var buster_position := Vector2(17, -2)

func _enter() -> void:
    owner.is_climbing = true
    animation_player.play(
        "climb_shoot_alt" if weapons.current_state.use_alt_anim else "climb_shoot")
    mega_buster.position = buster_position
    shoot()

func _exit() -> void:
    owner.is_climbing = false

func _handle_command(command: String) -> void:
    if command == "shoot":
        animation_player.seek(0)
        shoot()
    if command == "drop_down":
        emit_signal("finished", "jump")
    if command.begins_with("weapon_"):
        weapons.change_weapon(command)
        
func _update(delta: float) -> void:
    # collision_shape.shape.extents.y = 12
    var direction: Vector2 = get_input_direction()
    if direction.x != 0:
        last_shooting_direction = direction
        update_sprite_direction(last_shooting_direction)

func _on_animation_finished(anim_name: String) -> void:
    emit_signal("finished", "climb")
