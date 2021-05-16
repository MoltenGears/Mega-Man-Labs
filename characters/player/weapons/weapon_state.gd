extends State

export(String) var weapon_name := ""
export(int) var energy_cost := 1
export(Color) var color_primary: Color
export(Color) var color_secondary: Color

var weapon_energy: int = Constants.HIT_POINTS_MAX setget , _get_weapon_energy
var can_power_charge: bool = false
var _charge_playback_position: float = 0.0

onready var charge_sound: AudioStreamPlayer = get_node("../../SFX/ChargeWeapon")

func _get_weapon_energy() -> int:
    return weapon_energy

func _enter() -> void:
    owner.swap_color(color_primary, color_secondary)
    owner.emit_signal("weapon_changed", weapon_energy, color_primary)

func _update(delta: float) -> void:
    if not owner.can_charge_weapon:
        return

    if Global.in_pause_menu:
        if charge_sound.playing:
            _charge_playback_position = charge_sound.get_playback_position()
            charge_sound.stop()
        return

    if can_power_charge and Global.is_action_pressed("action_shoot") and not owner.is_dead:
        if _charge_playback_position != 0:
            charge_sound.play(_charge_playback_position)

        if (owner.charge_duration <= Constants.CHARGE_DURATION_LVL1
                and owner.charge_duration + delta > Constants.CHARGE_DURATION_LVL1):
            charge_sound.play()
            owner.play_special_animation("power_charge_lvl1")
        if (owner.charge_duration <= Constants.CHARGE_DURATION_LVL2
                and owner.charge_duration + delta > Constants.CHARGE_DURATION_LVL2):
            owner.play_special_animation("power_charge_lvl2")

        owner.charge_duration += delta
    elif not owner.buffering_charge:
        owner.charge_duration = 0
        charge_sound.stop()
        owner.stop_special_animation()

    _charge_playback_position = 0.0

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
