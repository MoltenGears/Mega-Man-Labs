tool
extends Control

const FILL_DELAY: float = 0.05

export(Color) var color := Color("e7e794") setget set_bar_color

var _is_updating := false

onready var _overlay = $"MarginContainer/TextureRect/ColorRect"

signal gradual_update_complete()

func _ready() -> void:
    if Engine.editor_hint:
        visible = false

func on_restarted() -> void:
        visible = true
        update_instant(Constants.HIT_POINTS_MAX)

func on_hit_points_changed(hit_points: int) -> void:
    if hit_points < _get_current_hp_bar():
        update_instant(hit_points)
    elif hit_points > _get_current_hp_bar():
        update_gradual(hit_points)

func update_instant(hit_points: int) -> void:
    _set_current_hp_bar(hit_points)

func update_gradual(hit_points) -> void:
    if _is_updating:
        return
    
    Global.can_toggle_pause = false
    _is_updating = true
    var was_paused: bool = get_tree().paused
    get_tree().paused = true
    $FillSound.play()
    while round(clamp(hit_points, 0, Constants.HIT_POINTS_MAX)) != round(_get_current_hp_bar()):
        yield(get_tree().create_timer(FILL_DELAY), "timeout")
        _set_current_hp_bar(_get_current_hp_bar() + sign(hit_points - _get_current_hp_bar()))
    $FillSound.stop()
    get_tree().paused = was_paused
    _is_updating = false
    emit_signal("gradual_update_complete")
    Global.can_toggle_pause = true

func set_bar_color(value: Color) -> void:
    if has_node("MarginContainer/TextureRect/ColorOverlay"):
        $"MarginContainer/TextureRect/ColorOverlay".modulate = value
        color = value

func _set_current_hp_bar(hit_points: int) -> void:
    _overlay["rect_size"].y = clamp(2 * (Constants.HIT_POINTS_MAX - hit_points) - 1, 0, 2 * Constants.HIT_POINTS_MAX - 1)

func _get_current_hp_bar() -> int:
    return int(round(Constants.HIT_POINTS_MAX - (_overlay["rect_size"].y + 1) / 2))
