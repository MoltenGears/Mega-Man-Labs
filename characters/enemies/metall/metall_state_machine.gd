extends "res://characters/enemies/base/scripts/enemy_state_machine.gd"

func _ready() -> void:
    states_map["shoot"] = $Shoot
    states_map["idle"] = $Idle
