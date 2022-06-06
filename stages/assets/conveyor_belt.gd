tool
extends StaticBody2D

export(int) var velocity := 60 setget _set_velocity
export(String, "Left", "Right") var direction := "Left" setget _set_direction
export(int, 4, 24) var size := 8 setget _change_size
export(bool) var active := true setget _set_active

func _ready() -> void:
    _update()

func _set_velocity(value: int) -> void:
    velocity = value
    _update()

func _set_direction(value: String) -> void:
    direction = value
    _update()

func _set_active(value: bool) -> void:
    active = value
    _update()

func _change_size(value: int) -> void:
    size = value
    _update()

func _update() -> void:
    if not has_node("CollisionShape2D"):
        return

    var dir: int = -1 if direction == "Left" else 1
    constant_linear_velocity.x = velocity * dir if active else 0

    var extents := Vector2(size * 8, 8)
    $CollisionShape2D.position = extents
    $CollisionShape2D.shape.extents = extents

    var last_index: int = size - 3
    var i: int = 0
    for sprite in $SpriteInbetweens.get_children():
        sprite.visible = i <= last_index
        sprite.position.x = 24 + i * 16
        sprite.flip_h = dir > 0
        sprite.playing = active
        sprite.frame = 0
        i += 1

    $SpriteEnd.position.x = 40 + last_index * 16
    $SpriteEnd.flip_h = dir > 0
    $SpriteEnd.playing = active
    $SpriteStart.flip_h = dir > 0
    $SpriteStart.playing = active
