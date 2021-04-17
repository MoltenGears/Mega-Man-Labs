extends State

export(int) var energy_cost := 3

const Projectile: Resource = preload("res://characters/bosses/thunder_man/ThunderManElectricStrike.tscn")

var weapon_energy: int = Constants.HIT_POINTS_MAX

onready var mega_buster: Position2D = get_node("../../MegaBusterPos")

func _enter() -> void:
    owner.swap_color(Color.violet, Color.silver)
    owner.emit_signal("weapon_changed", weapon_energy, Color.violet)

func use() -> void:
    if not deplete_energy():
        return

    var bolt = Projectile.instance()
    mega_buster.position.x = abs(mega_buster.position.x) * owner.get_facing_direction().x
    bolt.position = mega_buster.global_position
    owner.get_parent().add_child(bolt)

func deplete_energy() -> bool:
    if weapon_energy - energy_cost < 0:
        return false
    else:
        weapon_energy -= energy_cost
        owner.emit_signal("weapon_energy_changed", weapon_energy)
        return true

func charge_energy(amount: int) -> void:
    weapon_energy = clamp(weapon_energy + amount, 0, Constants.HIT_POINTS_MAX)
    owner.emit_signal("weapon_energy_changed", weapon_energy)
