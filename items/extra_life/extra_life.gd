extends "res://items/pick_up_base/pick_up_base.gd"

onready var _audio := $AudioStreamPlayer

func _on_picked_up_effect(body: Player) -> void:
    _audio.play()
    GameState.extra_life_count += 1

func queue_free() -> void:
    if _audio.playing:
        yield(_audio, "finished")
    .queue_free()
