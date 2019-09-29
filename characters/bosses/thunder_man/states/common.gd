extends State

const ElectricBall: Resource = preload("res://characters/bosses/thunder_man/ThunderManElectricBall.tscn")
const COOLDOWN: float = 0.7

var velocity := Vector2()

onready var _shoot_pos: Position2D = $"../../Position2D"

onready var _ray_cast: RayCast2D = $"../../RayCast2D"
onready var _ray_cast_length: float = _ray_cast.cast_to.length()
onready var timer_cooldown: Timer = $"../../TimerCooldown"
onready var animated_sprite: AnimationPlayer = $"../../CharacterSprites/AnimatedSprite"
onready var effects: AnimationPlayer = $"../../AnimationEffects"

func _handle_input(event: InputEvent) -> void:
    if event.is_action_pressed("action_debug_01"):
        pass

func _on_animation_finished(anim_name: String) -> void:
    if anim_name == "hit":
        owner.is_invincible = false

func jump() -> void:
    if owner.is_on_floor() and timer_cooldown.is_stopped():
        timer_cooldown.start(COOLDOWN + randf() * 0.6)
        emit_signal("finished", "jump")
    else:
        emit_signal("finished", "idle")

func shoot() -> void:
    var electric_ball := ElectricBall.instance()
    _shoot_pos.position.x = abs(_shoot_pos.position.x) * owner.get_facing_direction().x
    electric_ball.global_position = _shoot_pos.global_position
    electric_ball.direction = owner.get_facing_direction()
    if not owner.is_restarting:
        owner.get_parent().add_child(electric_ball)
