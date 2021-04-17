extends Node2D

export(String) var start_scene_release = "res://menus/TitleScreen.tscn"
export(String) var start_scene_debug = "res://stages/heat/HeatStage.tscn"

var _current_scene_path: String
var current_scene: Node = null

onready var _game_vp: Viewport = _find_viewport_leaf(self)
onready var _game_vpc: ViewportContainer = _game_vp.get_parent()

func _ready() -> void:
    _game_vp.size = Global.base_size
    _game_vpc.material.set_shader_param("screen_base_size", Global.base_size.y)
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
