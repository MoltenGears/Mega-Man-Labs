tool
extends Node

enum Filter {
    # Applicable to GLES2 and GLES3
    PIXEL_ART_UPSCALE,
    CRT_LOTTES,
    LINEAR, # Keep as last GLES2 entry since its value is used in wrapi() for cycling through.

    # GLES3 only.
    PIXEL_ART_UPSCALE_GLES3,
    CRT_EASYMODE # Keep as last entry since its value is used in wrapi() for cycling through.
}

export(PackedScene) var start_scene_release
export(PackedScene) var start_scene_debug
export(Filter) var filter setget _set_filter

var _current_scene_path: String
var current_scene: Node = null

onready var _game_vp: Viewport = _find_viewport_leaf(self)
onready var _game_vpc: ViewportContainer = _game_vp.get_parent()

func _physics_process(delta: float) -> void:
    if not Engine.editor_hint and $Label.visible:
        $Label.text = str(Engine.get_frames_per_second(), " FPS")

func _ready() -> void:
    if Engine.is_editor_hint():
        return

    Global.connect("internal_res_changed", self, "_on_size_changed")
    get_tree().get_root().connect("size_changed", self, "_on_size_changed")
    _on_size_changed()
    _game_vpc.set_process_unhandled_input(true)
    _game_vp.get_texture().flags = Texture.FLAG_FILTER # Required for pixel art upscaling shaders.
    _set_filter(filter)

    if OS.is_debug_build() and start_scene_debug:
        switch_scene(start_scene_debug.resource_path)
    elif start_scene_release:
        $Backdrop.visible = true
        OS.window_fullscreen = true
        switch_scene(start_scene_release.resource_path)
    else:
        push_error("'%s' node has no startup scene set." % self.name)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("action_screenshot"):
        Global.take_screenshot()
    if event.is_action_pressed("action_debug_filter"):
        if OS.get_current_video_driver() == OS.VIDEO_DRIVER_GLES2:
            _set_filter(wrapi(filter + 1, 0, Filter.LINEAR + 1))
        else:
            _set_filter(wrapi(filter + 1, 0, Filter.CRT_EASYMODE + 1))
    if event.is_action_pressed("action_debug_fullscreen"):
        OS.window_fullscreen = !OS.window_fullscreen

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

func _set_filter(filter_value: int) -> void:
    filter = filter_value

    if not _game_vpc or Engine.editor_hint:
        return

    match filter_value:
        Filter.PIXEL_ART_UPSCALE:
            # print_debug("Setting filter to Pixel Art Upscale (GLES2).")
            _game_vpc.material = ShaderMaterial.new()
            _game_vpc.material.shader = load("res://shaders/pixel_art_upscale_filter_gles2.tres")
            _game_vpc.material.set_shader_param("texture_size", Global.base_size)
            _game_vpc.material.set_shader_param("texels_per_pixel", 1.0 / _game_vpc.rect_scale.x)
        Filter.PIXEL_ART_UPSCALE_GLES3:
            # print_debug("Setting filter to Pixel Art Upscale (GLES3).")
            _game_vpc.material = ShaderMaterial.new()
            _game_vpc.material.shader = load("res://shaders/pixel_art_upscale_filter_gles3.tres")
            _game_vpc.material.set_shader_param("blur", 1)
        Filter.CRT_LOTTES:
            # print_debug("Setting filter to CRT Lottes.")
            _game_vpc.material = load("res://effects/crt_lottes.tres")
            _game_vpc.material.set_shader_param("InputSize", Global.base_size)
            _game_vpc.material.set_shader_param("TextureSize", Global.base_size)
        Filter.CRT_EASYMODE:
            # print_debug("Setting filter to CRT Easymode.")
            _game_vpc.material = load("res://effects/crt_easymode.tres")
            _game_vpc.material.set_shader_param("screen_base_size", Global.base_size.y) # TODO: Needs to be fixed.
        Filter.LINEAR:
            # print_debug("Setting filter to Linear.")
            _game_vpc.material = null

func _on_size_changed() -> void:
    var update_filter: bool = _game_vp.size != Global.base_size
    _game_vp.size = Global.base_size
    
    get_tree().set_screen_stretch(
        get_tree().STRETCH_MODE_2D,
        get_tree().STRETCH_ASPECT_KEEP,
        OS.window_size,
        1)
    
    var window_aspect_ratio: float = OS.window_size.x / OS.window_size.y
    var game_aspect_ratio: float = _game_vp.size.x / _game_vp.size.y

    var width: float
    var height: float
    
    if window_aspect_ratio < game_aspect_ratio:
        width = OS.window_size.x
        height = width / game_aspect_ratio
        _game_vpc.rect_position = Vector2(0, (OS.window_size.y - height) / 2)
    else:
        height = OS.window_size.y
        width = height * game_aspect_ratio
        _game_vpc.rect_position = Vector2((OS.window_size.x - width) / 2, 0)

    _game_vpc.rect_size = Vector2(width, height)
    _game_vpc.rect_scale = Vector2(width, height) / _game_vp.size

    if update_filter:
        _set_filter(filter)

    if filter == Filter.PIXEL_ART_UPSCALE and _game_vpc.material:
        # Always needs update on size change.
        _game_vpc.material.set_shader_param("texels_per_pixel", 1.0 / _game_vpc.rect_scale.x)
