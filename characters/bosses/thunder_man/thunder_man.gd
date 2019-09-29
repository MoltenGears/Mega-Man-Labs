extends "res://characters/bosses/base/boss_base.gd"

func reset() -> void:
    .reset()
    $"CharacterSprites/Sprite".visible = false
    set_facing_direction(Vector2.LEFT)

func set_facing_direction(dir: Vector2) -> void:
    .set_facing_direction(dir)
    $"CharacterSprites/Sprite".flip_h = true if dir == Vector2.RIGHT else false

func face_player() -> void:
    if Global.player is Player:
        set_facing_direction(Vector2(sign(Global.player.global_position.x - global_position.x), 0))
