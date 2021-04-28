tool
extends Control

const FILL_DELAY: float = 0.05

export(String) var bar_name := ""
export(Color) var color := Color("e7e794") setget set_bar_color
export(bool) var horizontal := false setget set_bar_orientation
export(bool) var fill_with_sound := true

var _is_updating := false

onready var _overlay = $"TextureRect/ColorRect"
onready var _overlay_h = $"TextureRectHorizontal/ColorRect"

signal gradual_update_complete()

func _ready() -> void:
    pass
    # if Engine.editor_hint:
    #     visible = false

func on_restarted() -> void:
        visible = true
        update_instant(Constants.HIT_POINTS_MAX)

func on_hit_points_changed(hit_points: int) -> void:
    if hit_points < _get_current_hp_bar():
        update_instant(hit_points)
    elif hit_points > _get_current_hp_bar():
        update_gradual(hit_points)

func on_weapon_changed(weapon_energy: int, new_color: Color) -> void:
    if new_color == Color.transparent:
        visible = false
    else:
        set_bar_color(new_color)
        update_instant(weapon_energy)
        visible = true

func update_instant(hit_points: int) -> void:
    _set_current_hp_bar(hit_points)

func update_gradual(hit_points) -> void:
    if _is_updating:
        return
    
    Global.can_toggle_pause = false
    _is_updating = true
    var was_paused: bool = get_tree().paused
    get_tree().paused = true
    if fill_with_sound:
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
    if has_node("TextureRect/ColorOverlay") and has_node("TextureRectHorizontal/ColorOverlay"):
        $"TextureRect/ColorOverlay".modulate = value
        $"TextureRectHorizontal/ColorOverlay".modulate = value
        color = value

func set_bar_orientation(is_horizontal: bool) -> void:
    if has_node("TextureRectHorizontal") and has_node("TextureRect"):
        $"TextureRect".visible = !is_horizontal
        $"TextureRectHorizontal".visible = is_horizontal
        horizontal = is_horizontal

func _set_current_hp_bar(hit_points: int) -> void:
    var offset := clamp(2 * (Constants.HIT_POINTS_MAX - hit_points) - 1, 0, 2 * Constants.HIT_POINTS_MAX - 1)
    if horizontal:
        _overlay_h["rect_size"].x = offset
        _overlay_h["rect_position"].x = 2 * Constants.HIT_POINTS_MAX - offset
    else:
        _overlay["rect_size"].y = offset

func _get_current_hp_bar() -> int:
    if horizontal:
        return int(round(Constants.HIT_POINTS_MAX - (_overlay_h["rect_size"].x + 1) / 2))
    else:
        return int(round(Constants.HIT_POINTS_MAX - (_overlay["rect_size"].y + 1) / 2))
