extends State

onready var _trigger_area = $"../../TriggerArea"

func _enter() -> void:
    owner.is_blocking = true
    $"../../EnemyAnimations".play("idle")

func on_Timer_timeout() -> void:
    if _trigger_area.player:
        # Change facing direction if necessary
        var vector_to_player: Vector2 = _trigger_area.player.global_position - $"../../Area2D".global_position
        if sign(owner.get_facing_direction().x) != sign(vector_to_player.x):
            owner.toggle_flip_h()
            
        emit_signal("finished", "shoot")
    else:
        _trigger_area.is_shot_ready = true
