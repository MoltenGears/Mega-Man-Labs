extends Node2D

export(int) var damage := 7

onready var _area := $Area2D

func _ready() -> void:
    $AnimationPlayer.connect("animation_finished", self, "_on_animation_finished")
    $AnimationPlayer.play("flash")

func _physics_process(delta: float) -> void:
    for body in _area.get_overlapping_bodies():
        if body is Player:
            body.on_hit(damage)

func _on_animation_finished(anim_name: String) -> void:
    queue_free()
