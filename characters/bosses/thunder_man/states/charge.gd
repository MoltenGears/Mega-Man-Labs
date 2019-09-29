extends "common.gd"

export(float) var charge_time := 0.33

var _time: float

func _enter() -> void:
    animated_sprite.play("idle")
    _time = 0

func _update(delta: float) -> void:
    _time += delta
    if _time > charge_time:
        emit_signal("finished", "dash")
