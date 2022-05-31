extends "common.gd"

const ElectricStrike: Resource = preload("res://characters/bosses/thunder_man/ThunderManElectricStrike.tscn")

var _electric_strike: Node2D
var _strike_pos: Vector2

onready var _animation_player := $"../../AnimationPlayer"
onready var _timer_electric_strike := $"../../TimerElectricStrike"
onready var _timer_strike_position := $"../../TimerStrikePosition"

func _ready() -> void:
    _timer_electric_strike.connect("timeout", self, "_on_strike_timeout")
    _timer_strike_position.connect("timeout", self, "_on_strike_pos_timeout")

func _enter() -> void:
    _animation_player.play("strike_prep")
    _electric_strike = ElectricStrike.instance()
    _timer_electric_strike.start()
    _timer_strike_position.start()

func _on_animation_finished(anim_name: String) -> void:
    ._on_animation_finished(anim_name)
    if anim_name == "strike_prep":
        emit_signal("finished", "idle")

func _get_strike_pos() -> Vector2:
    var x: float = owner.global_position.x
    if Global.player is Player:
        x = Global.player.global_position.x

    var y: float = owner.global_position.y + \
            owner.get_node("Area2D/CollisionShape2D").shape.extents.y - \
            _electric_strike.get_node("Area2D/CollisionShape2D").shape.extents.y + 2

    return Vector2(x, y)

func _on_strike_pos_timeout() -> void:
    _strike_pos = _get_strike_pos()

func _on_strike_timeout() -> void:
    if not owner.is_restarting:
        owner.get_parent().add_child(_electric_strike)
        _electric_strike.global_position = _strike_pos
