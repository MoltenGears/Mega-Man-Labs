extends "res://items/pick_up_base/pick_up_base.gd"

func _on_picked_up_effect(body: Player) -> void:
    $AudioStreamPlayer.play()
    GameState.extra_life_count += 1
