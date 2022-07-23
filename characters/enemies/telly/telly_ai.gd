extends AI

func _get_input_direction() -> Vector2:
    if Global.player:
        return owner.global_position.direction_to(Global.player.global_position)
    else:
        return Vector2.ZERO
