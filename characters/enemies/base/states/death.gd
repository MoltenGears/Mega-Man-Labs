extends State

onready var _animations: AnimationPlayer = $"../../BaseAnimations"

func _enter() -> void:
    _animations.play("death")

func _on_animation_finished(anim_name: String) -> void:
    if anim_name == "death":
        owner.queue_free()
