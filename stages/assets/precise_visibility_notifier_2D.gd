extends VisibilityNotifier2D

class_name PreciseVisibilityNotifier2D

export(bool) var enabled := true setget set_enabled, is_enabled
export(int) var margin := 0

var _was_on_screen: bool
var _is_on_screen: bool
var _sign: int

onready var _viewport := get_viewport()
onready var _viewport_rect: Rect2
onready var _rect: Rect2
onready var _base_size: Vector2

signal camera_entered()
signal camera_exited()

func _ready() -> void:
    set_enabled(enabled)
    _base_size = Vector2(ProjectSettings.get_setting("display/window/size/width"),
            ProjectSettings.get_setting("display/window/size/height"))
    force_visibility_update()
    _was_on_screen = is_on_screen()

func _physics_process(delta: float) -> void:
    force_visibility_update()
    _is_on_screen = is_on_screen()

    if not _was_on_screen and _is_on_screen:
        emit_signal("camera_entered")
    elif _was_on_screen and not _is_on_screen:
        emit_signal("camera_exited")
    
    _was_on_screen = _is_on_screen

func is_on_screen() -> bool:
    _sign = 1 if _was_on_screen else -1
    _viewport_rect = _viewport_rect.grow(_sign * margin)
    return _viewport_rect.intersects(_rect)

func force_visibility_update() -> void:
    _viewport_rect = Rect2(-_viewport.get_canvas_transform().origin, _base_size)
    _rect = Rect2(global_position + rect.position, rect.size)

func set_enabled(value: bool) -> void:
    set_physics_process(value)
    enabled = value

func is_enabled() -> bool:
    return is_physics_processing()
