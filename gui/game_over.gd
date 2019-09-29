extends Control

onready var _continue_button := $"CenterContainer/Buttons/ContinueButton"
onready var _title_screen_button := $"CenterContainer/Buttons/TitleScreenButton"

func _ready() -> void:
    _continue_button.connect("button_up", self, "_on_continue_pressed")
    _title_screen_button.connect("button_up", self, "_on_title_screen_pressed")
    $GameOverMusic.connect("finished", self, "_on_music_finished")

func show_game_over() -> void:
    self.visible = true
    $GameOverMusic.play()

func _on_continue_pressed() -> void:
    if Global.main_scene.has_method("reload_current_scene"):
        Global.main_scene.reload_current_scene()

func _on_title_screen_pressed() -> void:
    Global.main_scene.switch_scene("res://menus/TitleScreen.tscn")

func _on_music_finished() -> void:
    _continue_button.grab_focus()
