extends State

export(String) var weapon_name := ""
export(int) var energy_cost := 1
export(Color) var color_primary: Color
export(Color) var color_secondary: Color

var weapon_energy: int = Constants.HIT_POINTS_MAX setget , _get_weapon_energy

func _get_weapon_energy() -> int:
    return weapon_energy

func _enter() -> void:
    owner.swap_color(color_primary, color_secondary)
    owner.emit_signal("weapon_changed", weapon_energy, color_primary)

func _deplete_energy() -> bool:
    if weapon_energy - energy_cost < 0:
        return false
    else:
        weapon_energy -= energy_cost
        owner.emit_signal("weapon_energy_changed", weapon_energy)
        return true

func charge_energy(amount: int) -> void:
    weapon_energy = clamp(weapon_energy + amount, 0, Constants.HIT_POINTS_MAX)
    owner.emit_signal("weapon_energy_changed", weapon_energy)
