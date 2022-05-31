tool
extends Node2D

const Spawner: Resource = preload("res://stages/assets/Spawner.tscn")

export(String) var enemy_name: String
export(int) var hit_points_max := 20
export(int) var contact_damage := 5
export(bool) var can_respawn := true
export(int) var spawn_count_max := -1
export(float) var spawn_timer := 0.0
export(bool) var flip_direction := false setget set_flip_direction

var _hit_points: int
var _is_collidable := true
var _player_collision_area: Area2D
var _timer: Timer
var spawn_info := {}
var is_dead := false
var is_blocking := false

onready var _hit_sound: AudioStreamPlayer = get_node("SFX/Hit")
onready var _animations: AnimationPlayer = $BaseAnimations
onready var _start_pos: Vector2 = position

signal change_state(state_name)
signal queued_free()

func _ready() -> void:
    connect("change_state", $StateMachine, "_change_state")
    if has_node("Area2D"):
        _player_collision_area = $Area2D
        _player_collision_area.connect("body_entered", self, "_on_hit")
    _hit_points = hit_points_max
    add_to_group("enemies")

func _replace_with_spawner() -> void:
    spawn_info["flip_direction"] = flip_direction

    if not can_respawn:
        return

    var spawner: Position2D = Spawner.instance()
    spawner.packed_scene_ref = load(filename)
    spawner.position = _start_pos
    spawner.spawn_info = spawn_info
    spawner.spawn_count_max = spawn_count_max
    spawner.spawn_timer = spawn_timer
    get_parent().add_child(spawner)
    queue_free()

func _physics_process(delta: float) -> void:
    if _player_collision_area:
        for body in _player_collision_area.get_overlapping_bodies():
            if body is Player and _is_collidable:
                body.on_hit(contact_damage)

func _on_hit(body: PhysicsBody2D) -> void:
    if body and body.is_in_group("PlayerWeapons"):
        if "consumed" in body and body.consumed:
            return
        elif is_blocking:
            body.reflect()
        else:
            _hit_sound.play()
            var buster_damage: int = 1 if not "damage" in body else body.damage
            if buster_damage <= _hit_points:
                body.queue_free()
            _animations.play("blink")
            _take_damage(buster_damage)

func _take_damage(damage: int) -> void:
    _hit_points -= damage
    if _hit_points < 1:
        _die()

func _die() -> void:
    is_dead = true
    _is_collidable = false  # Player can no longer collide with enemy.
    if _player_collision_area:
        # Is no longer hittable by player projectiles.
        _player_collision_area.set_collision_layer_bit(2, false)
    emit_signal("change_state", "death")

func toggle_flip_h() -> void:
    $Sprite.flip_h = !$Sprite.flip_h

func set_flip_direction(value: bool) -> void:
    $Sprite.flip_h = value
    flip_direction = value

func get_facing_direction() -> Vector2:
    return Vector2.RIGHT if $Sprite.flip_h else Vector2.LEFT

func on_camera_exited() -> void:
    queue_free()

func start_yield_timer(time: float) -> Timer:
    _timer = Timer.new()
    add_child(_timer)
    _timer.start(time)
    return _timer

func queue_free() -> void:
    emit_signal("queued_free")
    if _timer and _timer.time_left > 0:
        yield(_timer, "timeout")
    .queue_free()
