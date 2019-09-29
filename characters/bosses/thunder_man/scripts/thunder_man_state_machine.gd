extends "res://characters/bosses/base/scripts/boss_state_machine.gd"

func _ready() -> void:
    states_map["move"] = $Move
    states_map["charge"] = $Charge
    states_map["dash"] = $Dash
    states_map["shoot"] = $Shoot
    states_map["electric_strike"] = $ElectricStrike
