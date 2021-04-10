extends KinematicBody2D

# Player controller class that makes an in-game character playable.
class_name Player

export(bool) var can_slide := true

var hit_points: int
var is_controllable := true setget set_controllable
var is_invincible := false
var is_dead := false
var is_climbing := false
var is_sliding := false
var is_still := false
var explode_on_death := true
var ladder: StaticBody2D
var gravity: float = Constants.GRAVITY

onready var _ray_cast: RayCast2D = $"CollisionShape2D/RayCast2D";
onready var _animation_player: AnimationPlayer = $AnimationPlayer

signal change_state(state_name)
signal hit_points_changed(hit_points)
signal died()
signal exited()

func _ready() -> void:
    connect("change_state", $StateMachine, "_change_state")

func on_restarted() -> void:
    visible = false

func on_ready() -> void:
    hit_points = Constants.HIT_POINTS_MAX
    $StateMachine.initialize($StateMachine.start_state)

func on_camera_transition_start() -> void:
    if _animation_player.current_animation == "move" or is_climbing:
        _animation_player.pause_mode = PAUSE_MODE_PROCESS
    if is_climbing:
        _animation_player.play("climb_move")

func on_camera_transition_end() -> void:
    _animation_player.pause_mode = PAUSE_MODE_INHERIT

func on_boss_entered() -> void:
    if is_on_floor():
        emit_signal("change_state", "idle")
    else:
        emit_signal("change_state", "jump")

func on_boss_died() -> void:
    is_invincible = true
    set_controllable(false)

func on_stage_cleared() -> void:
    $"Cutscenes/StageClear".start()

func on_hit(damage: int) -> void:
    if not is_invincible:
        is_invincible = true
        _take_damage(damage)
        if not is_dead:
            emit_signal("change_state", "stagger")
            get_node("SFX/Hit").play()

func heal(life_energy: int) -> void:
    hit_points = clamp(hit_points + life_energy, 0, Constants.HIT_POINTS_MAX)
    emit_signal("hit_points_changed", hit_points)

func die(explode: bool = true) -> void:
    if not is_dead:
        explode_on_death = explode
        emit_signal("hit_points_changed", 0)
        emit_signal("change_state", "death")
        emit_signal("died")

func set_facing_direction(value: Vector2) -> void:
    if value == Vector2.RIGHT:
        $Sprite.flip_h = false
    elif value == Vector2.LEFT:
        $Sprite.flip_h = true

func get_facing_direction() -> Vector2:
    return Vector2.LEFT if $Sprite.flip_h else Vector2.RIGHT

func toggle_flip_h() -> void:
    $Sprite.flip_h = !$Sprite.flip_h

func climb(correction_distance: Vector2) -> void:
    move_and_collide(correction_distance)
    emit_signal("change_state", "climb")

func stop_climb() -> void:
    if is_climbing:
        emit_signal("change_state", "idle")

func check_for_space(dir: Vector2, transition_shape_extents: Vector2) -> bool:
    var is_space_empty := true
    var player_extents: Vector2 = $CollisionShape2D.shape.extents
    var cast_to_temp: Vector2 = _ray_cast.cast_to
    var ray_pos_temp: Vector2 = _ray_cast.position
    
    _ray_cast.cast_to = dir * (player_extents + \
            2 * transition_shape_extents + Vector2(16, 32))    # 16 => one tile horizontal
    _ray_cast.force_raycast_update()
    is_space_empty = is_space_empty and not _ray_cast.is_colliding()
    _ray_cast.position += player_extents * Vector2(dir.y, dir.x) * 0.9
    _ray_cast.force_raycast_update()
    is_space_empty = is_space_empty and not _ray_cast.is_colliding()
    _ray_cast.position -= 2 * player_extents * Vector2(dir.y, dir.x) * 0.9
    _ray_cast.force_raycast_update()
    is_space_empty = is_space_empty and not _ray_cast.is_colliding()

    _ray_cast.position = ray_pos_temp
    _ray_cast.cast_to = cast_to_temp
    return is_space_empty

func set_controllable(value: bool) -> void:
    is_controllable = value
    if value == false:
        $StateMachine.input_direction = Vector2()

func _take_damage(damage: int) -> void:
    hit_points -= damage
    emit_signal("hit_points_changed", hit_points)
    if hit_points < 1:
        die()
