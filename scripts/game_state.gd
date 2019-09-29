extends Node

var extra_life_count: int setget _set_extra_life_count
var energy_tank_count: int setget _set_energy_tank_count

signal extra_life_count_changed(extra_life_count)
signal energy_tank_count_changed(tank_count)

func _ready() -> void:
    reset()

func reset() -> void:
    extra_life_count = 2
    energy_tank_count = 0

func update_all() -> void:
    emit_signal("extra_life_count_changed", extra_life_count)
    emit_signal("energy_tank_count_changed", energy_tank_count)

func _set_extra_life_count(value: int) -> void:
    extra_life_count = clamp(value, 0, 9)
    emit_signal("extra_life_count_changed", extra_life_count)

func _set_energy_tank_count(value: int) -> void:
    energy_tank_count = clamp(value, 0, 9)
    emit_signal("energy_tank_count_changed", energy_tank_count)
