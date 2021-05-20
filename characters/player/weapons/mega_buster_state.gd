extends "res://characters/player/weapons/weapon_state.gd"

const Projectile: Resource = preload("MegaBuster.tscn")
const ProjectileCharged1: Resource = preload("MegaBusterCharged1.tscn")
const ProjectileCharged2: Resource = preload("MegaBusterCharged2.tscn")

onready var mega_buster: Position2D = get_node("../../MegaBusterPos")

func _ready() -> void:
    can_power_charge = true

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
    var on_screen_bullets: Array = get_tree().get_nodes_in_group(
        "BusterProjectilesP%s" % owner.player_number)

    for bullet in on_screen_bullets:
        if bullet.name == "MegaBusterCharged2":
            return

    if on_screen_bullets.size() < owner.max_on_screen_projectiles:
        mega_buster.position.x = abs(mega_buster.position.x) * owner.get_facing_direction().x
        owner.get_parent().add_child(_get_bullet())

func _get_bullet() -> Node:
    var bullet: Node
    match owner.charge_level:
        0:
            bullet = Projectile.instance()
        1:
            bullet = ProjectileCharged1.instance()
        2:
            bullet = ProjectileCharged2.instance()

    bullet.position = mega_buster.global_position
    bullet.direction = owner.get_facing_direction()
    bullet.add_to_group("BusterProjectilesP%s" % owner.player_number)

    return bullet
