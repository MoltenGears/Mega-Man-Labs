extends Control

const BLUR_AMOUNT_START: float = 0.1
const BLUR_AMOUNT_STOP: float = 2.0
const BLUR_TWEEN_DURATION: float = 0.08

var _is_game_paused := false
var _can_pause := true setget set_can_pause

onready var _pause_shader := $ShaderEffects
onready var _blur_effect := $"ShaderEffects/Blur"
onready var _tween := $"ShaderEffects/Tween"
onready var _energy_tank_button := $"CenterContainer/Menu/EnergyTankContainer/EnergyTankButton"
onready var _focus_frame := $FocusFrame

signal game_paused()
signal game_resumed()

func _ready() -> void:
    _tween.connect("tween_completed", self, "_on_tween_completed")
    _energy_tank_button.connect("button_up", self, "use_energy_tank")
    _energy_tank_button.connect("focus_entered", self, "_on_focus_entered",
            [_energy_tank_button.rect_global_position])
    _energy_tank_button.connect("focus_exited", self, "_on_focus_exited")

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("action_pause") and Global.can_toggle_pause:
        if not get_tree().paused and not _is_game_paused:
            pause_game()
        elif _is_game_paused:
            resume_game()

func pause_game() -> void:
    if not _can_pause:
        return

    GameState.update_all()
    emit_signal("game_paused")
    get_tree().paused = true
    visible = true
    _is_game_paused = true
    _pause_shader.visible = true
    _tween.interpolate_property(_blur_effect.material, "shader_param/amount",
            BLUR_AMOUNT_START, BLUR_AMOUNT_STOP, BLUR_TWEEN_DURATION,
            Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    _tween.start()
    _energy_tank_button.grab_focus()

func resume_game() -> void:
    emit_signal("game_resumed")
    get_tree().paused = false
    visible = false
    _is_game_paused = false
    _tween.interpolate_property(_blur_effect.material, "shader_param/amount",
            BLUR_AMOUNT_STOP, BLUR_AMOUNT_START, BLUR_TWEEN_DURATION,
            Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    _tween.start()

func set_can_pause(value):
    _can_pause = value

func use_energy_tank() -> void:
    if Global.player and GameState.energy_tank_count > 0 and \
            Global.player.hit_points < Constants.HIT_POINTS_MAX:
        GameState.energy_tank_count -= 1
        Global.player.heal(Constants.HIT_POINTS_MAX)

func on_extra_life_count_changed(value: int) -> void:
    $"CenterContainer/Menu/LifeContainer/LifeLabel".text = str(" 0", value, " /09")

func on_energy_tank_count_changed(value: int) -> void:
    $"CenterContainer/Menu/EnergyTankContainer/EnergyTankLabel".text = str(" 0", value, " /09")

func _on_tween_completed(object: Object, key: String) -> void:
    if not _is_game_paused:
        _pause_shader.visible = false

func _on_focus_entered(rect_global_pos: Vector2) -> void:
    _focus_frame.rect_global_position = rect_global_pos
    _focus_frame.visible = true

func _on_focus_exited() -> void:
    _focus_frame.visible = false
