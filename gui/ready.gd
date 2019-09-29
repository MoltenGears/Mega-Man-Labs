extends MarginContainer

func on_restarted() -> void:
    $AnimationPlayer.play("ready")
    visible = true

func on_ready() -> void:
    visible = false
    $AnimationPlayer.stop()
