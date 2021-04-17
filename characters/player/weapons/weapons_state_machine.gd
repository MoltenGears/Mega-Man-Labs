extends StateMachine

func _ready() -> void:
    _init_states_map()

func change_weapon(name: String) -> void:
    # Mega Buster (+ 1) is not included in unlocked weapons.
    if states_map.size() != GameState.unlocked_weapons.size() + 1:
        _init_states_map()

    if name == "weapon_next":
        _change_state(_get_adjacent_key())
    elif name == "weapon_previous":
        _change_state(_get_adjacent_key(true))
    elif states_map.keys().has(name.substr(7)):  # Remove weapon_ prefix.
        _change_state(name.substr(7))
    else:
        printerr("Failed to change weapon. %s is not a valid weapon name." % name)

func _get_adjacent_key(previous: bool = false) -> String:
    var keys: Array = states_map.keys()
    var current_key: String

    for key in keys:
        if states_map[key] == current_state:
            current_key = key
    
    var adjacent_index: int = 0
    var current_index: int = keys.find(current_key)

    if current_index < 0:
        printerr("Failed to map weapon states key to currently equipped weapon state.")
    elif not previous and current_index == keys.size() - 1:
        adjacent_index = 0
    else:
        adjacent_index = current_index - 1 if previous else current_index + 1

    return keys[adjacent_index]

func _init_states_map() -> void:
    states_map.clear()
    states_map["mega_buster"] = $MegaBuster

    if GameState.unlocked_weapons.has("thunder_strike"):
        states_map["thunder_strike"] = $ThunderStrike
