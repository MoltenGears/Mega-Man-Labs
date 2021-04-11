extends Node2D

const DeathParticle: Resource = preload("assets/DeathParticle.tscn")
const DEATH_PARTICLE_VELOCITY: int = 30
const ENERGY_PARTICLE_VELOCITY: int = 120

var effects_node: Node

signal energy_particles_vanished()

func _ready() -> void:
    $Timer.connect("timeout", self, "_on_timeout")
    var node_name := "SpawnedEffects"
    if not get_viewport().has_node(node_name):
        effects_node = Node.new()
        effects_node.name = node_name
        get_viewport().call_deferred("add_child", effects_node)
    else:
        effects_node = get_viewport().get_node(node_name)

func spawn_death_particles(spawn_pos: Vector2 = global_position) -> void:
    var death_particle: Node2D
    for i in range(8):
        death_particle = DeathParticle.instance()
        death_particle.initialize(
            spawn_pos, Vector2(1, 0).rotated(i * PI / 4), DEATH_PARTICLE_VELOCITY)
        effects_node.call_deferred("add_child", death_particle)
        
        death_particle = DeathParticle.instance()
        death_particle.initialize(
            spawn_pos, Vector2(1, 0).rotated(i * PI / 4), DEATH_PARTICLE_VELOCITY * 2)
        effects_node.call_deferred("add_child", death_particle)

func spawn_energy_particles(spawn_pos: Vector2 = global_position) -> void:
    $"SFX/Energy".play()
    var lifetime: float = $"SFX/Energy".stream.get_length()
    var distance: float = 200.0
    var factor: float = 1.5
    $Timer.start(lifetime * factor)
    var energy_particle: Node2D
    for i in range(8):
        energy_particle = DeathParticle.instance()
        energy_particle.set_lifetime(lifetime * factor)
        energy_particle.initialize(
                spawn_pos + Vector2(distance, 0).rotated(i * PI / 4),
                -Vector2(1, 0).rotated(i * PI / 4), distance / lifetime / factor )
        effects_node.call_deferred("add_child", energy_particle)
        
        energy_particle = DeathParticle.instance()
        energy_particle.set_lifetime(lifetime)
        energy_particle.initialize(
                spawn_pos + Vector2(distance, 0).rotated(i * PI / 4),
                -Vector2(1, 0).rotated(i * PI / 4), distance / lifetime)
        effects_node.call_deferred("add_child", energy_particle)

func _on_timeout() -> void:
    emit_signal("energy_particles_vanished")
