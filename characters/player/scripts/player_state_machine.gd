extends StateMachine

var input_direction := Vector2()
var locked := false

func _ready() -> void:
    states_map = {
        "spawn": $Spawn,
        "idle": $Idle,
        "move": $Move,
        "jump": $Jump,
        "jump_shoot": $JumpShoot,
        "slide": $Slide,
        "stagger": $Stagger,
        "climb": $Climb,
        "climb_shoot": $ClimbShoot,
        "death": $Death
    }

func _change_state(state_name: String) -> void:
    if not active or locked:
        return

    if state_name in ["placeholder"]:
        states_stack.push_front(states_map[state_name])
    if state_name == "jump_shoot" and current_state == $Jump:
        $JumpShoot.preset($Jump.velocity)
    if state_name == "jump" and current_state == $JumpShoot:
        $Jump.preset($JumpShoot.velocity)
    if state_name == "jump" and current_state == $Slide:
        $Jump.preset($Slide.velocity)
    if state_name == "jump" and current_state == $Stagger:
        $Jump.preset($Stagger.velocity)
    if state_name != "move" and current_state == $Idle:
        owner.is_still = false

    ._change_state(state_name)

func _physics_process(delta: float) -> void:
    if owner.is_controllable:
        input_direction = Vector2(int(Global.is_action_pressed("action_right")) - int(Global.is_action_pressed("action_left")),
                int(Global.is_action_pressed("action_down")) - int(Global.is_action_pressed("action_up")))

func _unhandled_input(event: InputEvent) -> void:
    if not owner.is_controllable or not current_state or not current_state.has_method("_handle_command"):
        return

    if event.is_action_pressed("action_jump") and Global.is_action_pressed("action_down"):
        current_state._handle_command("slide")

    if event.is_action_pressed("action_jump"):
        current_state._handle_command("jump")
    
    if event.is_action_released("action_jump"):
        current_state._handle_command("jump_stop")

    if event.is_action_pressed("action_shoot"):
        current_state._handle_command("shoot")
        
    if event.is_action_pressed("action_jump") and \
            not Global.is_action_pressed("action_up") and \
            not Global.is_action_pressed("action_down"):
        current_state._handle_command("drop_down")

func send_command(command: String) -> void:
    if current_state:
        current_state._handle_command(command)
