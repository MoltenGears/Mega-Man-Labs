extends "res://characters/player/weapons/weapon_state.gd"

const Projectile: Resource = preload("res://characters/bosses/thunder_man/ThunderManElectricStrike.tscn")

onready var mega_buster: Position2D = get_node("../../MegaBusterPos")

func use() -> void:
    if not _deplete_energy():
        return

    var bolt = Projectile.instance()
    mega_buster.position.x = abs(mega_buster.position.x) * owner.get_facing_direction().x
    bolt.position = mega_buster.global_position
    owner.get_parent().add_child(bolt)
