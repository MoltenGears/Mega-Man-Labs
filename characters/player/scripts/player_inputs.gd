extends InputHandler

func _unhandled_input(event: InputEvent) -> void:
    if (controller == Controller.EMPTY
        or not _get_state()
        or not _get_state().has_method("_handle_command")):
        return

    if (event.is_action_pressed(_get_name(Action.JUMP))
        and is_action_pressed(Action.DOWN)
        and not Global.use_touch_controls):
        _get_state()._handle_command("slide")
    elif Input.is_action_just_pressed(_get_name(Action.SLIDE)):
        # Using Input.is_action_just_pressed() for touch buttons to prevent continuous input events.
        _get_state()._handle_command("slide")

    if event.is_action_pressed(_get_name(Action.JUMP)):
        _get_state()._handle_command("jump")
    
    if event.is_action_released(_get_name(Action.JUMP)):
        _get_state()._handle_command("jump_stop")

    if event.is_action_pressed(_get_name(Action.SHOOT)):
        _get_state()._handle_command("shoot")

    if event.is_action_pressed(_get_name(Action.JUMP)) and \
            not is_action_pressed(Action.UP) and \
            not is_action_pressed(Action.DOWN):
        _get_state()._handle_command("drop_down")

    if event.is_action_pressed(_get_name(Action.WEAPON_NEXT)):
        _get_state()._handle_command("weapon_next")

    if event.is_action_pressed(_get_name(Action.WEAPON_PREVIOUS)):
        _get_state()._handle_command("weapon_previous")

func send(command: String) -> void:
    if _get_state():
        _get_state()._handle_command(command)

func _get_state() -> State:
    return $"../StateMachine".current_state
