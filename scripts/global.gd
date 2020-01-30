extends Node

const SCREENSHOT_PATH := "user://screenshots/"
const SCREENSHOT_NAME := "MMGScrnShot"
const DATETIME_FORMAT := "%02d"

var main_scene: Node
var current_stage: Stage setget , get_current_stage
var player: Player setget , get_player
var can_toggle_pause := true

func _ready() -> void:
    # Last child of root is always main scene
    var root := get_tree().get_root()
    main_scene = root.get_child(root.get_child_count() - 1)

    # Hide mouse
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func get_current_stage() -> Stage:
    if main_scene is Stage:
        return main_scene as Stage
    elif "current_scene" in main_scene and main_scene.current_scene is Stage:
        return main_scene.current_scene as Stage
    else:
        printerr("Could not get current stage because currently no stage is loaded.")
        return null

func get_player() -> Player:
    return get_current_stage().player

func take_screenshot() -> void:
    var dir: Directory = Directory.new()
    if not dir.dir_exists(SCREENSHOT_PATH):
        dir.make_dir(SCREENSHOT_PATH)

    var datetime := OS.get_datetime()
    datetime["year"] = (DATETIME_FORMAT % datetime["year"]).substr(2, 2)
    datetime["month"] = DATETIME_FORMAT % datetime["month"]
    datetime["day"] = DATETIME_FORMAT % datetime["day"]
    datetime["hour"] = DATETIME_FORMAT % datetime["hour"]
    datetime["minute"] = DATETIME_FORMAT % datetime["minute"]
    datetime["second"] = DATETIME_FORMAT % datetime["second"]
    var screenshot_filename := str(SCREENSHOT_PATH, SCREENSHOT_NAME, "_",
            datetime["month"], datetime["day"], datetime["year"], "_",
            datetime["hour"], datetime["minute"], datetime["second"], ".png")

    if dir.file_exists(screenshot_filename):
        printerr("Could not save screenshot. File already exists.")
        return

    var image := get_viewport().get_texture().get_data()
    image.flip_y()
    image.save_png(screenshot_filename)
