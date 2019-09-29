extends "res://items/pick_up_base/pick_up_base.gd"

func _ready() -> void:
    $"Sprite/AnimationPlayer".play("Blink")

func _on_picked_up_effect(body: Player) -> void:
    $AudioStreamPlayer.play()
    GameState.energy_tank_count += 1
