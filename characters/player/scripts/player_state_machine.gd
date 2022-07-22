extends StateMachine

var input_direction := Vector2()
var locked := false

onready var _inputs: InputHandler = $"../Inputs"

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
    input_direction = _inputs.get_input_direction()
