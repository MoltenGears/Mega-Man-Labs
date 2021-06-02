extends "res://characters/player/weapons/weapon_state.gd"

const Projectile: Resource = preload("res://characters/player/weapons/electric_ball/ElectricBall.tscn")

onready var mega_buster: Position2D = get_node("../../MegaBusterPos")

func use() -> void:
    var on_screen_bullets: Array = get_tree().get_nodes_in_group(
        "BusterProjectilesP%s" % owner.player_number)

    if on_screen_bullets.size() < owner.max_on_screen_projectiles:
        if not _deplete_energy():
            return

        mega_buster.position.x = abs(mega_buster.position.x) * owner.get_facing_direction().x

        var ball = Projectile.instance()
        ball.position = mega_buster.global_position
        ball.direction = owner.get_facing_direction()
        ball.add_to_group("BusterProjectilesP%s" % owner.player_number)
        owner.get_parent().add_child(ball)
