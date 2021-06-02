extends Node

var extra_life_count: int setget _set_extra_life_count
var energy_tank_count: int setget _set_energy_tank_count
var unlocked_weapons: Array = ["electric_ball"]
var enemies_count: Dictionary = {}

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

func increase_enemy_count(enemy_name: String) -> void:
    if not enemies_count.has(enemy_name):
        enemies_count[enemy_name] = 0
    enemies_count[enemy_name] += 1
    # print_debug("Enemy Count++ (%s): %s" % [enemy_name, enemies_count[enemy_name]])

func decrease_enemy_count(enemy_name: String) -> void:
    if enemies_count.has(enemy_name):
        enemies_count[enemy_name] -= 1
        # print_debug("Enemy Count-- (%s): %s" % [enemy_name, enemies_count[enemy_name]])
    
        if enemies_count[enemy_name] < 0:
            printerr("Enemy Count (%s) is smaller than 0: %s" % [enemy_name, enemies_count[enemy_name]])

func get_enemy_count(enemy_name: String) -> int:
    if enemies_count.has(enemy_name):
        return enemies_count[enemy_name]
    else:
        return 0

func reset_enemy_count() -> void:
    GameState.enemies_count.clear()
    # print_debug("Reset Enemy Count for all types to 0.")

func _set_extra_life_count(value: int) -> void:
    extra_life_count = clamp(value, 0, 9)
    emit_signal("extra_life_count_changed", extra_life_count)

func _set_energy_tank_count(value: int) -> void:
    energy_tank_count = clamp(value, 0, 9)
    emit_signal("energy_tank_count_changed", energy_tank_count)
