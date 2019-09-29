extends Control

var main_buttons: Array
var new_game_button: Button
var options_button: Button
var exit_button: Button

func _ready() -> void:
    _create_main_buttons()
    if not OS.is_debug_build():
        $TitleMusic.play()

func _input(event: InputEvent) -> void:
    if (event is InputEventJoypadButton or event is InputEventKey) and not event.pressed:
        set_process_input(false)
        $"MarginContainer/VBoxContainer/Buttons".remove_child($"MarginContainer/VBoxContainer/Buttons/StartLabel")
        _show_main_buttons()
    
func _show_main_buttons() -> void:
    for button in main_buttons:
        $"MarginContainer/VBoxContainer/Buttons".add_child(button)
    new_game_button.grab_focus()

func _new_game() -> void:
    for button in $"MarginContainer/VBoxContainer/Buttons".get_children():
        button.disabled = true
    $TitleMusic.stop()
    $FadeEffects.fade_out(0.15)
    yield($FadeEffects, "screen_faded_out")
    Global.main_scene.switch_scene("res://stages/test_lab/TestLab.tscn")

func _options() -> void:
    pass

func _exit() -> void:
    get_tree().quit()

func _create_main_buttons() -> void:
    new_game_button = _create_button("New Game", "_new_game")
    main_buttons.push_back(new_game_button)
    options_button = _create_button("Options", "_options")
    main_buttons.push_back(options_button)
    exit_button = _create_button("Exit", "_exit")
    main_buttons.push_back(exit_button)

func _create_button(text: String, callback: String) -> Button:
    var button := Button.new()
    button.text = text
    button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    button.mouse_filter = Control.MOUSE_FILTER_IGNORE
    button.connect("button_down", self, callback)
    return button
