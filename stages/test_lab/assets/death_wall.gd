extends Node2D

export(float) var speed := 75
export(int) var travel_distance_tiles := 10

var _start_pos: Vector2
var _distance_traveled: float

func _ready() -> void:
    _start_pos = global_position
    add_to_group("SpecialsReset")
    $TriggerStart.connect("body_entered", self, "_on_body_entered")
    $"Sprite/AnimationPlayer".play("arcing")
    set_physics_process(false)
    _distance_traveled = 0

func on_restarted() -> void:
    set_physics_process(false)
    global_position = _start_pos
    _distance_traveled = 0

func _physics_process(delta: float) -> void:
    global_position += Vector2.RIGHT * speed * delta
    _distance_traveled += speed * delta
    if _distance_traveled > travel_distance_tiles * 16:
        set_physics_process(false)

func _on_body_entered(body: KinematicBody2D) -> void:
    if body is Player:
        set_physics_process(true)
