extends "common.gd"

export(float) var dash_duration := 0.15
export(int) var dash_speed := 600

var _duration: float

onready var dash_effect: Sprite = $"../../DashEffect"

func _enter() -> void:
    _duration = 0
    animated_sprite.play("dash")
    dash_effect.set_as_toplevel(true)
    dash_effect.global_position = owner.global_position
    dash_effect.flip_h = animated_sprite.flip_h
    $"../../AnimationEffects".play("dash_effect")

func _update(delta: float) -> void:
    owner.move_and_collide(owner.get_facing_direction() * dash_speed * delta)
    _duration += delta
    if _duration > dash_duration:
        emit_signal("finished", "idle")
