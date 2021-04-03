extends Node2D

var _current_scene_path: String
var current_scene: Node = null

func _ready() -> void:
    $"ViewportContainer/Viewport".size.x = Global.base_size.x
    $"ViewportContainer/Viewport".size.y = Global.base_size.y
    $"ViewportContainer".material.set_shader_param("screen_base_size", Global.base_size.y)
    $ViewportContainer.set_process_unhandled_input(true)

    if not OS.is_debug_build():
        switch_scene("res://menus/TitleScreen.tscn")
    else:
        switch_scene("res://stages/test_lab/TestLab.tscn")

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("action_screenshot"):
        Global.take_screenshot()
    if event.is_action_pressed("action_debug_crt"):
        $ViewportContainer.use_parent_material = !$ViewportContainer.use_parent_material
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
    _get_most_inner_viewport().add_child(current_scene)

func _get_most_inner_viewport() -> Viewport:
    var viewport: Viewport = null
    var child: Node = self
    while child.get_child_count() > 0:
        child = child.get_child(0)
        if child is Viewport:
            viewport = child
    
    if not viewport:
        print("No child Viewport node found below \'", name, "\'.")
    return viewport
