extends Node2D

class_name AppearingBlock

export(int, 1, 10) var index := 1

func _ready() -> void:
    $Sprite.visible = false
    $AnimationPlayer.connect("animation_finished", self, "_on_anim_finished")
    $PreciseVisibilityNotifier2D.connect("camera_entered", self, "_on_camera_entered")

func appear() -> void:
    $AnimationPlayer.play("appear_disappear")
    $"StaticBody2D/CollisionShape2D".set_deferred("disabled", false)

func is_on_screen() -> bool:
    return $PreciseVisibilityNotifier2D.is_on_screen()

func _on_anim_finished(_anim_name: String) -> void:
    $"StaticBody2D/CollisionShape2D".set_deferred("disabled", true)

func _on_camera_entered() -> void:
    get_parent().set_active()
