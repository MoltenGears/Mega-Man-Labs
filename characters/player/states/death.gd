extends "common.gd"

const FREEZE_TIME: float = 0.24    # Seconds

func _enter() -> void:
    # Stop state machine
    get_parent().set_active(false)
    owner.is_dead = true
    owner.buffering_charge = false

    # Short screen freeze before death explosion.
    # Is not working as expected as is. Incorrect animation state is frozen.
    # var pause_mode_temp = animation_player.pause_mode
    # animation_player.pause_mode = PAUSE_MODE_STOP
    # get_tree().paused = true
    # yield(get_tree().create_timer(FREEZE_TIME), "timeout")
    # get_tree().paused = false
    # animation_player.pause_mode = pause_mode_temp

    # Vanish and explode
    owner.visible = false
    $"../../SFX/Death".play()
    if owner.explode_on_death:
        explode()

func explode() -> void:
    $"../../EffectSpawner".spawn_death_particles()
