extends StateMachine

var action_left: String setget , _get_action_left
var action_right: String setget , _get_action_right
var action_up: String setget , _get_action_up
var action_down: String setget , _get_action_down
var action_jump: String setget , _get_action_jump
var action_shoot: String setget , _get_action_shoot
var action_weapon_next: String setget , _get_action_weapon_next
var action_weapon_previous: String setget , _get_action_weapon_previous

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
        input_direction = Vector2(int(Global.is_action_pressed(_get_action_right())) - int(Global.is_action_pressed(_get_action_left())),
                int(Global.is_action_pressed(_get_action_down())) - int(Global.is_action_pressed(_get_action_up())))

func _unhandled_input(event: InputEvent) -> void:
    if not owner.is_controllable or not current_state or not current_state.has_method("_handle_command"):
        return

    if event.is_action_pressed(_get_action_jump()) and Global.is_action_pressed(_get_action_down()):
        current_state._handle_command("slide")

    if event.is_action_pressed(_get_action_jump()) and not Global.is_action_pressed(_get_action_down()):
        current_state._handle_command("slide_jump")

    if event.is_action_pressed(_get_action_jump()):
        current_state._handle_command("jump")
    
    if event.is_action_released(_get_action_jump()):
        current_state._handle_command("jump_stop")

    if event.is_action_pressed(_get_action_shoot()):
        current_state._handle_command("shoot")

    if event.is_action_pressed(_get_action_jump()) and \
            not Global.is_action_pressed(_get_action_up()) and \
            not Global.is_action_pressed(_get_action_down()):
        current_state._handle_command("drop_down")

    if event.is_action_pressed(_get_action_weapon_next()):
        current_state._handle_command("weapon_next")

    if event.is_action_pressed(_get_action_weapon_previous()):
        current_state._handle_command("weapon_previous")

func send_command(command: String) -> void:
    if current_state:
        current_state._handle_command(command)


func _get_action_left() -> String:
    return "action_left_p%s" % owner.player_number

func _get_action_right() -> String:
    return "action_right_p%s" % owner.player_number

func _get_action_up() -> String:
    return "action_up_p%s" % owner.player_number

func _get_action_down() -> String:
    return "action_down_p%s" % owner.player_number

func _get_action_jump() -> String:
    return "action_jump_p%s" % owner.player_number

func _get_action_shoot() -> String:
    return "action_shoot_p%s" % owner.player_number

func _get_action_weapon_next() -> String:
    return "action_weapon_next_p%s" % owner.player_number

func _get_action_weapon_previous() -> String:
    return "action_weapon_previous_p%s" % owner.player_number
