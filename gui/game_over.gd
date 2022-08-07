extends Control

onready var _continue_button := $"CenterContainer/Buttons/ContinueButton"
onready var _title_screen_button := $"CenterContainer/Buttons/TitleScreenButton"

func _ready() -> void:
    _continue_button.connect("button_up", self, "_on_continue_pressed")
    _continue_button.connect("focus_entered", self, "_on_focus_entered", [null])
    _continue_button.connect("mouse_entered", self, "_on_focus_entered", [_continue_button])
    _title_screen_button.connect("button_up", self, "_on_title_screen_pressed")
    _title_screen_button.connect("focus_entered", self, "_on_focus_entered", [null])
    _title_screen_button.connect("mouse_entered", self, "_on_focus_entered", [_title_screen_button])
    $GameOverMusic.connect("finished", self, "_on_music_finished")

func show_game_over() -> void:
    self.visible = true
    $GameOverMusic.play()

func _on_continue_pressed() -> void:
    _continue_button.disconnect("focus_entered", self, "_on_focus_entered")
    _continue_button.release_focus()
    $SelectSound.play()
    yield($SelectSound, "finished")
    if Global.main_scene.has_method("reload_current_scene"):
        Global.main_scene.reload_current_scene()

func _on_title_screen_pressed() -> void:
    _title_screen_button.disconnect("focus_entered", self, "_on_focus_entered")
    _title_screen_button.release_focus()
    $SelectSound.play()
    yield($SelectSound, "finished")
    Global.main_scene.switch_scene("res://menus/TitleScreen.tscn")

func _on_focus_entered(button: Button) -> void:
    if button: # Handle mouse/touch.
        if button.has_focus():
            return
        else:
            button.grab_focus()

    $MoveCursorSound.play()

func _on_music_finished() -> void:
    _continue_button.grab_focus()
