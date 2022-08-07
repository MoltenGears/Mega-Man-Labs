extends Node

# Base class for handling user or AI inputs.
class_name InputHandler

enum Controller {
    EMPTY = 0,
    PLAYER_1 = 1,
    PLAYER_2 = 2,
    PLAYER_3 = 3,
    PLAYER_4 = 4,
    AI = 100
}

enum Action {
    UP,
    DOWN,
    RIGHT,
    LEFT,
    SHOOT,
    JUMP,
    SLIDE,
    WEAPON_NEXT,
    WEAPON_PREVIOUS
}

var controller: int = Controller.EMPTY
var ai: AI = AI.new()

func get_input_direction() -> Vector2:
    if controller == Controller.EMPTY:
        return Vector2.ZERO
    elif controller == Controller.AI:
        return ai._get_input_direction()
    else:
        var right := int(Global.is_action_pressed(_get_name(Action.RIGHT)))
        var left := int(Global.is_action_pressed(_get_name(Action.LEFT)))
        var down := int(Global.is_action_pressed(_get_name(Action.DOWN)))
        var up := int(Global.is_action_pressed(_get_name(Action.UP)))
        return Vector2(right - left, down - up)

func is_action_pressed(action: int) -> bool:
    var action_name: String = _get_name(action)
    if controller == Controller.EMPTY or action_name.empty():
        return false
    else:
        return Global.is_action_pressed(action_name)

func _get_name(action: int) -> String:
    match action:
        Action.UP:
            return "action_up_p%s" % controller
        Action.DOWN:
            return "action_down_p%s" % controller
        Action.LEFT:
            return "action_left_p%s" % controller
        Action.RIGHT:
            return "action_right_p%s" % controller
        Action.SHOOT:
            return "action_shoot_p%s" % controller
        Action.JUMP:
            return "action_jump_p%s" % controller
        Action.SLIDE:
            return "action_slide_p%s" % controller
        Action.WEAPON_NEXT:
            return "action_weapon_next_p%s" % controller
        Action.WEAPON_PREVIOUS:
            return "action_weapon_previous_p%s" % controller
        _:
            return ""
