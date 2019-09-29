extends StateMachine

func _ready() -> void:
    states_map = {
        "death": $Death
    }

func _change_state(state_name: String) -> void:
    if current_state == $Death:
        return
    ._change_state(state_name)
