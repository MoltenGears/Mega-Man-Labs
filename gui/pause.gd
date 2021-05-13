extends Control

const BLUR_AMOUNT_START: float = 0.1
const BLUR_AMOUNT_STOP: float = 2.0
const BLUR_TWEEN_DURATION: float = 0.08

var _is_game_paused := false
var _can_pause := true setget set_can_pause
var _bars_node_path: String = "Weapons"
var _weapon_buttons: Array
var _first_focus: bool = true

onready var _pause_shader := $ShaderEffects
onready var _blur_effect := $"ShaderEffects/Blur"
onready var _tween := $"ShaderEffects/Tween"
onready var _energy_tank_button := $"Menu/EnergyTankContainer/EnergyTankButton"
onready var _focus_frame := $FocusFrame

signal game_paused()
signal game_resumed()

func _ready() -> void:
    _tween.connect("tween_completed", self, "_on_tween_completed")
    _energy_tank_button.connect("button_up", self, "use_energy_tank")
    _energy_tank_button.connect("focus_entered", self, "_on_focus_entered",
            [_energy_tank_button.rect_global_position])
    _energy_tank_button.connect("focus_exited", self, "_on_focus_exited")

    _get_weapon_buttons()
    for weapon_button in _weapon_buttons:
        weapon_button.connect(
            "focus_entered", self, "_on_focus_entered", [weapon_button.rect_global_position])
        weapon_button.connect("focus_exited", self, "_on_focus_exited")
        weapon_button.connect(
            "button_up", self, "_on_weapon_button_pressed", [weapon_button.get_parent().bar_name])

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
    _update_weapon_bars()
    emit_signal("game_paused")
    get_tree().paused = true
    visible = true
    _is_game_paused = true
    _pause_shader.visible = true
    _tween.interpolate_property(_blur_effect.material, "shader_param/amount",
            BLUR_AMOUNT_START, BLUR_AMOUNT_STOP, BLUR_TWEEN_DURATION,
            Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    _tween.start()
    _set_button_focus()
    _first_focus = false
    $WeaponMenuSound.play()

func resume_game() -> void:
    _first_focus = true
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

func _update_weapon_bars() -> void:
    if _bars_node_path.empty():
        return

    var weapons_info: Dictionary = Global.get_player().get_weapons_info()
    for bar in get_node(_bars_node_path).get_children():
        if weapons_info.keys().has(bar.bar_name):
            bar.visible = true
            bar.update_instant(weapons_info[bar.bar_name][0])
            bar.color = weapons_info[bar.bar_name][1]
        else:
            bar.visible = false

func _get_weapon_buttons() -> void:
    _weapon_buttons.clear()
    for bar in get_node(_bars_node_path).get_children():
        for child in  bar.get_children():
            if child is Button:
                _weapon_buttons.append(child)
                break

func _set_button_focus() -> void:
    var current_weapon_name: String = Global.player.get_current_weapon_name()
    for button in _weapon_buttons:
        if button.get_parent().bar_name == current_weapon_name:
            button.grab_focus()
            return
    _energy_tank_button.grab_focus()

func use_energy_tank() -> void:
    if Global.player and GameState.energy_tank_count > 0 and \
            Global.player.hit_points < Constants.HIT_POINTS_MAX:
        GameState.energy_tank_count -= 1
        Global.player.heal(Constants.HIT_POINTS_MAX)
    get_node(_bars_node_path).get_children()[0].update_gradual(Constants.HIT_POINTS_MAX)

func on_extra_life_count_changed(value: int) -> void:
    $"Menu/LifeContainer/LifeLabel".text = str(" 0", value, " /09")

func on_energy_tank_count_changed(value: int) -> void:
    $"Menu/EnergyTankContainer/EnergyTankLabel".text = str(" 0", value, " /09")

func _on_tween_completed(object: Object, key: String) -> void:
    if not _is_game_paused:
        _pause_shader.visible = false

func _on_focus_entered(rect_global_pos: Vector2) -> void:
    _focus_frame.rect_global_position = rect_global_pos
    _focus_frame.visible = true

func _on_focus_exited() -> void:
    _focus_frame.visible = false
    if not _first_focus:
        $MoveCursorSound.play()

func _on_weapon_button_pressed(bar_name: String) -> void:
    Global.player.change_weapon(str("weapon_", bar_name))
