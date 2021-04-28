extends "res://characters/player/weapons/weapon_state.gd"

const Projectile: Resource = preload("MegaBuster.tscn")

onready var mega_buster: Position2D = get_node("../../MegaBusterPos")

func _get_weapon_energy() -> int:
    return owner.hit_points

func _enter() -> void:
    owner.reset_color()
    owner.emit_signal("weapon_changed", 0, Color.transparent)

func _deplete_energy() -> bool:
    return true  # Cannot deplete mega buster.

func charge_energy(amount: int) -> void:
    pass  # Cannot charge mega buster.

func use() -> void:
    if get_tree().get_nodes_in_group("MegaBusterProjectiles").size() < Constants.PROJECTILE_COUNT_MAX:
        var bullet = Projectile.instance()
        mega_buster.position.x = abs(mega_buster.position.x) * owner.get_facing_direction().x
        bullet.position = mega_buster.global_position
        bullet.direction = owner.get_facing_direction()
        owner.get_parent().add_child(bullet)
