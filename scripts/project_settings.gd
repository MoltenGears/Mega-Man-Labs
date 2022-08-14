tool
extends Node

func _ready() -> void:
    _init_custom_project_settings()

# Initializes project settings custom properties.
func _init_custom_project_settings() -> void:
    
    if not ProjectSettings.has_setting("custom/startup/entry_game_scene"):
        ProjectSettings.set_setting("custom/startup/entry_game_scene", "res://menus/TitleScreen.tscn")
    if not ProjectSettings.has_setting("custom/startup/entry_game_scene.debug"):
        ProjectSettings.set_setting("custom/startup/entry_game_scene.debug", "res://stages/heat/HeatStage.tscn")
    ProjectSettings.set_initial_value("custom/startup/entry_game_scene", "res://menus/TitleScreen.tscn")
    ProjectSettings.set_initial_value("custom/startup/entry_game_scene.debug", "res://stages/heat/HeatStage.tscn")
    ProjectSettings.add_property_info({
        "name": "custom/startup/entry_game_scene",
        "type": TYPE_STRING,
        "hint": PROPERTY_HINT_FILE,
        "hint_string": "*.tscn,*.scn"
    })

    if not ProjectSettings.has_setting("custom/gui/touch_controls"):
        ProjectSettings.set_setting("custom/gui/touch_controls", false)
    if not ProjectSettings.has_setting("custom/gui/touch_controls.mobile"):
        ProjectSettings.set_setting("custom/gui/touch_controls.mobile", true)
    ProjectSettings.set_initial_value("custom/gui/touch_controls", false)
    ProjectSettings.set_initial_value("custom/gui/touch_controls.mobile", true)

    var gles2: bool = OS.get_current_video_driver() == OS.VIDEO_DRIVER_GLES2
    if not ProjectSettings.has_setting("custom/rendering/filter"):
        ProjectSettings.set_setting("custom/rendering/filter", 0 if gles2 else 3)
    ProjectSettings.set_initial_value("custom/rendering/filter", 0 if gles2 else 3)
    ProjectSettings.add_property_info({
        "name": "custom/rendering/filter",
        "type": TYPE_INT,
        "hint": PROPERTY_HINT_ENUM,
        "hint_string": "PIXEL_ART_UPSCALE,CRT_LOTTES,LINEAR,PIXEL_ART_UPSCALE_GLES3,CRT_EASYMODE"
    })

    if not ProjectSettings.has_setting("custom/gui/show_fps"):
        ProjectSettings.set_setting("custom/gui/show_fps", false)
    ProjectSettings.set_initial_value("custom/gui/show_fps", false)
