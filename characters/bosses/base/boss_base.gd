extends KinematicBody2D

export(int) var contact_damage := 3
export(int) var buster_damage := 3

var _hit_points: int
var _start_pos: Vector2
var _is_blocking: bool
var _is_collidable: bool
var is_invincible: bool
var is_dead: bool
var is_restarting: bool

onready var _base_width: int = Global.base_size.x
onready var _animated_sprite: AnimatedSprite = $"CharacterSprites/AnimatedSprite"
onready var life_bar: Control = Global.get_current_stage().get_node(
    "GUI/MarginContainer/LifeEnergyBar/BossBar")

signal change_state(state_name)
signal hit_points_changed(_hit_points)
signal boss_ready()
signal boss_died()

func _ready() -> void:
    connect("change_state", $StateMachine, "_change_state")
    connect("hit_points_changed", life_bar, "on_hit_points_changed")
    $Area2D.connect("body_entered", self, "_on_hit")
    _start_pos = global_position

func reset() -> void:
    is_restarting = true
    emit_signal("change_state", "await")
    $StateMachine.set_active(false)
    _animated_sprite.play("idle")
    visible = true
    is_dead = false
    _animated_sprite.visible = false
    life_bar.visible = false
    _hit_points = Constants.HIT_POINTS_MAX
    global_position = _start_pos
    is_invincible = true
    _is_blocking = false
    _is_collidable = true
    _animated_sprite.flip_h = false
    _animated_sprite.position = Vector2(0, -256)

func on_boss_entered() -> void:
    if Global.player is Player and abs(global_position.x - Global.player.global_position.x) < _base_width / 2:
        _switch_side()
    $StateMachine.initialize($"StateMachine/Ready".get_path())

func _physics_process(delta: float) -> void:
    if $Area2D:
        for body in $Area2D.get_overlapping_bodies():
            if body is Player and _is_collidable:
                body.on_hit(contact_damage)

func _on_hit(body: PhysicsBody2D) -> void:
    if is_invincible:
        return

    if body and body.is_in_group("PlayerWeapons"):
        if _is_blocking:
            body.reflect()
        else:
            is_invincible = true
            $"SFX/Hit".play()
            body.queue_free()
            $AnimationHit.play("hit")
            _take_damage(buster_damage)

func _take_damage(damage: int) -> void:
    _hit_points -= damage
    emit_signal("hit_points_changed", _hit_points)
    if _hit_points < 1:
        die()

func _switch_side() -> void:
    global_position.x -= (global_position - \
            Global.get_current_stage().get_current_camera().get_camera_screen_center()).x * 2
    if get_facing_direction() == Vector2.RIGHT:
        set_facing_direction(Vector2.LEFT)
    else:
        set_facing_direction(Vector2.RIGHT)

func die() -> void:
    is_dead = true
    visible = false
    _is_collidable = false
    emit_signal("change_state", "death")
    emit_signal("boss_died")

func set_facing_direction(dir: Vector2) -> void:
    _animated_sprite.flip_h = true if dir == Vector2.RIGHT else false

func get_facing_direction() -> Vector2:
    return Vector2.RIGHT if _animated_sprite.flip_h else Vector2.LEFT
