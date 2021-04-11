extends Node2D

# Items
export(int, 0, 9999) var weight_no_drop := 107

const LifeEnergySmall: Resource = preload("res://items/life_energy/LifeEnergySmall.tscn")
export(int, 0, 9999) var weight_life_energy_small := 15

const LifeEnergyBig: Resource = preload("res://items/life_energy/LifeEnergyBig.tscn")
export(int, 0, 9999) var weight_life_energy_big := 4

const ExtraLife: Resource = preload("res://items/extra_life/ExtraLife.tscn")
export(int, 0, 9999) var weight_extra_life := 1

const EnergyTank: Resource = preload("res://items/tanks/EnergyTank.tscn")
export(int, 0, 9999) var weight_energy_tank := 1

var _accumulated_weight: int

func drop_item() -> void:
    var item_drop = _roll_item()

    if item_drop:
        item_drop.global_position = global_position
        Global.get_current_stage().add_child(item_drop)

func _roll_item() -> Node:
    var total_weight: int = (
        weight_no_drop
        + weight_life_energy_small
        + weight_life_energy_big
        + weight_extra_life
        + weight_energy_tank
    )

    var roll: int = 0
    if total_weight > 0:
        roll += Global.rng.randi_range(1, total_weight)
    
    _accumulated_weight = weight_no_drop
    if (roll <= _accumulated_weight):
        return null

    _accumulated_weight += weight_life_energy_small
    if roll <= _accumulated_weight:
        return LifeEnergySmall.instance()

    _accumulated_weight += weight_life_energy_big
    if roll <= _accumulated_weight:
        return LifeEnergyBig.instance()

    _accumulated_weight += weight_extra_life
    if roll <= _accumulated_weight:
        return ExtraLife.instance()

    _accumulated_weight += weight_energy_tank
    if roll <= _accumulated_weight:
        return EnergyTank.instance()

    return null
