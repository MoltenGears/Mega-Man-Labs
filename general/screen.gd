tool
extends Node2D

export(String) var start_scene_release := "res://menus/TitleScreen.tscn"
export(String) var start_scene_debug := "res://stages/heat/HeatStage.tscn"
export(String, "easymode", "lottes") var crt_shader := "lottes" setget _set_crt_shader

var _current_scene_path: String
var current_scene: Node = null

onready var _game_vp: Viewport = _find_viewport_leaf(self)
onready var _game_vpc: ViewportContainer = _game_vp.get_parent()

func _ready() -> void:
    if Engine.is_editor_hint():
        return

    get_tree().connect("screen_resized", self, "on_screen_resized")
    Global.set_wide_screen(Global.wide_screen)  # Trigger pixel perfect scaling.
    _game_vpc.set_process_unhandled_input(true)

    if OS.is_debug_build():
        switch_scene(start_scene_debug)
    else:
        switch_scene(start_scene_release)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("action_screenshot"):
        Global.take_screenshot()
    if event.is_action_pressed("action_debug_crt"):
        _game_vpc.use_parent_material = !_game_vpc.use_parent_material
        on_screen_resized()
    if event.is_action_pressed("action_debug_fullscreen"):
        PixelPerfectScaling.fullscreen = !PixelPerfectScaling.fullscreen

func switch_scene(path: String) -> void:
    call_deferred("_deferred_switch_scene", path)

func reload_current_scene() -> void:
    switch_scene(_current_scene_path)

func _deferred_switch_scene(path):
    if current_scene:
        current_scene.free()

    _current_scene_path = path
    var new_scene: Resource = ResourceLoader.load(path)
    current_scene = new_scene.instance()
    _game_vp.add_child(current_scene)

func _find_viewport_leaf(node: Node) -> Viewport:
    for child_node in node.get_children():
        if child_node is Viewport and child_node.get_child_count() == 0:
            return child_node
        elif child_node.get_child_count() > 0:
            var viewport = _find_viewport_leaf(child_node)
            if viewport:
                return viewport
    
    print("No child Viewport node found below \'", name, "\'.")
    return null

func on_screen_resized() -> void:
    # Force same behavior of internal game viewport as root viewport with strech mode '2d'.
    # This allows upscaling of the internal game viewport and applying post-processing
    # shaders to the upscaled image. Furthermore, sub-pixel precision sprite movement
    # and camera scrolling is maintained if upscaled this way.
    # Disable this behavior if CRT shader is enabled (_game_vpc.use_parent_material == false).
    _game_vp.set_size_override(_game_vpc.use_parent_material, Global.base_size)
    _game_vp.set_size_override_stretch(_game_vpc.use_parent_material)

    # Sets root viewport stretch mode to 'viewport' instead of '2d' for this to work properly.
    get_viewport().set_size_override(false)

    # Resize viewport container (vpc).
    _game_vpc.rect_size = Global.base_size * Global.scale_factor

    # Upscale internal game viewport (vp) if desired.
    var scale: float = Global.scale_factor if _game_vpc.use_parent_material else 1.0
    _game_vp.size = Global.base_size * scale

    # CRT shaders are intended to be used without upscaling of the input.
    if crt_shader == "easymode":
        _game_vpc.material.set_shader_param("screen_base_size", Global.base_size.y)
    elif crt_shader == "lottes":
        _game_vpc.material.set_shader_param("InputSize", Global.base_size)
        _game_vpc.material.set_shader_param("TextureSize", Global.base_size)

func _set_crt_shader(value: String) -> void:
    crt_shader = value
    if not _game_vpc:
        return

    match value:
        "easymode":
            _game_vpc.material = load("res://effects/crt_easymode.tres")
        "lottes":
            _game_vpc.material = load("res://effects/crt_lottes.tres")

    if not Engine.is_editor_hint():
        on_screen_resized()
