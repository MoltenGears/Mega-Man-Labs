extends Node

var _distance_last_frame := Vector2()

onready var _player: Player = owner
onready var _state_machine := _player.get_node("StateMachine")
onready var _animation_player := _player.get_node("AnimationPlayer")
onready var _effect_spawner := _player.get_node("EffectSpawner")

func _ready() -> void:
    set_physics_process(false)

func _physics_process(delta: float) -> void:
    var distance_to_center: Vector2 = _get_distance_to_center()
    if abs(distance_to_center.x) < 2:
        _state_machine.input_direction = Vector2()
        owner.gravity = 6.0
        _state_machine.send_command("jump")

    if sign(distance_to_center.y) == -1 and sign(_distance_last_frame.y) == 1:
        _state_machine.current_state.velocity = Vector2()
        owner.gravity = 0.0
        set_physics_process(false)
        _exit()

    _distance_last_frame = distance_to_center

func start() -> void:
    set_physics_process(true)
    _state_machine.input_direction = Vector2(sign(_get_distance_to_center().x), 0)

func _exit() -> void:
    _effect_spawner.spawn_energy_particles()
    yield(_effect_spawner, "energy_particles_vanished")
    _effect_spawner.spawn_energy_particles()
    yield(_effect_spawner, "energy_particles_vanished")
    _effect_spawner.spawn_energy_particles()
    yield(_effect_spawner, "energy_particles_vanished")
    owner.gravity = Constants.GRAVITY
    yield(get_tree().create_timer(1.0), "timeout")
    _animation_player.play("exit")
    yield(get_tree().create_timer(1.0), "timeout")
    owner.emit_signal("exited")

func _get_distance_to_center() -> Vector2:
    return Global.current_stage.current_camera.get_camera_screen_center() - _player.global_position
