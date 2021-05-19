extends "common.gd"

const JUMP_SPEED: float = -285.0

var _velocity_init := Vector2()
var velocity := Vector2()

onready var landing_sound_effect: AudioStreamPlayer = owner.get_node("SFX/Land")

func preset(velocity_start: Vector2) -> void:
    _velocity_init = velocity_start

func _enter() -> void:
    animation_player.play("jump")
    velocity = _velocity_init
    _velocity_init = Vector2()

    if owner.is_on_floor():
        # Delay gravity by two frames to be able to jump three tiles high.
        # In Mega Man gravity is only applied in air, i.e., after first jump frame.
        # Not sure why a second gravity frame delay is necessary to reach 3 tiles high.
        velocity.y = JUMP_SPEED - owner.gravity * 2

func _handle_command(command: String) -> void:
    if command == "jump_stop" and velocity.y < 0:
        velocity.y = 0

    if command == "shoot":
        emit_signal("finished", "jump_shoot")
    
    if command.begins_with("weapon_"):
        weapons.change_weapon(command)

func _update(delta: float) -> void:
    if owner.charge_level > 0 and not Global.is_action_pressed(get_parent().action_shoot):
        _handle_command("shoot")

    var direction: Vector2 = get_input_direction()
    update_sprite_direction(direction)
    
    velocity.y = clamp(velocity.y + owner.gravity, -Constants.FALL_SPEED_MAX, Constants.FALL_SPEED_MAX)
    if owner.is_on_ceiling() and velocity.y < 0:
        velocity.y = 0
    velocity.x = Global.get_walk_speed() * direction.x
    owner.move_and_slide(velocity, Constants.FLOOR_NORMAL)

    if owner.is_on_floor():
        landing_sound_effect.play()
        emit_signal("finished", "idle")
