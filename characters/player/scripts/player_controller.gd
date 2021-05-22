extends KinematicBody2D

# Player controller class that makes an in-game character playable.
class_name Player

export(int, 1, 2) var player_number := 1
export(bool) var can_slide := true
export(bool) var can_charge_weapon := true
export(int, 1, 4) var damage_multiplier := 1
export(int, 1, 4) var knock_back_multiplier := 1
export(int, 1, 10) var max_on_screen_projectiles := 3

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
var charge_duration: float = 0
var charge_level: int setget , _get_charge_level
var buffering_charge: bool = false

onready var _ray_cast: RayCast2D = $"CollisionShape2D/RayCast2D";
onready var _animation_player: AnimationPlayer = $AnimationPlayer

signal change_state(state_name)
signal hit_points_changed(hit_points)
signal weapon_energy_changed(weapon_energy)
signal weapon_changed(weapon_energy, new_color)
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
    _animation_player.pause_mode = PAUSE_MODE_PROCESS
    if is_climbing:
        _animation_player.play("climb_move")
    elif _animation_player.current_animation == "idle":
        emit_signal("change_state", "move")
        _animation_player.play("move")

func on_camera_transition_end() -> void:
    _animation_player.pause_mode = PAUSE_MODE_INHERIT
    if not is_climbing and not is_sliding and is_on_floor():
        emit_signal("change_state", "idle")

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

func charge_weapon(weapon_energy: int) -> void:
    if $Weapons.current_state.has_method("charge_energy"):
        $Weapons.current_state.charge_energy(weapon_energy)

func change_weapon(weapon_name: String) -> void:
    $Weapons.change_weapon(weapon_name)

func get_weapons_info() -> Dictionary:
    return $Weapons.get_weapons_info()

func get_current_weapon_name() -> String:
    return $Weapons.current_state.weapon_name

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

func swap_color(main: Color, secondary: Color) -> void:
    $Sprite.material.set_shader_param("replace_0", main)
    $Sprite.material.set_shader_param("replace_1", secondary)
    $Sprite.use_parent_material = false

func reset_color() -> void:
    $Sprite.use_parent_material = true

func play_special_animation(anim_name: String) -> void:
    $"SpriteMask/AnimationSpecialEffects".play(anim_name)
    $SpriteMask.material.set_shader_param("enabled", true)

func stop_special_animation() -> void:
    $"SpriteMask/AnimationSpecialEffects".stop()
    $SpriteMask.material.set_shader_param("enabled", false)

func _take_damage(damage: int) -> void:
    hit_points -= damage * damage_multiplier
    emit_signal("hit_points_changed", hit_points)
    if hit_points < 1:
        die()

func _get_charge_level() -> int:
    var level: int = 0
    if charge_duration > Constants.CHARGE_DURATION_LVL1:
        level += 1
    if charge_duration > Constants.CHARGE_DURATION_LVL2:
        level += 1

    return level
