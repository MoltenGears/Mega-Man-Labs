extends State

func _enter() -> void:
    $"../../SFX/Death".play()
    $"../../EffectSpawner".spawn_death_particles()
