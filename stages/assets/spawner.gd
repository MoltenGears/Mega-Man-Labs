tool
extends Position2D

export(PackedScene) var packed_scene_ref: PackedScene setget set_packed_scene_ref

var _can_spawn := true
var spawn_info := {}

onready var _spawn_ref: Resource = load(packed_scene_ref.get_path())

func _ready() -> void:
    $PreciseVisibilityNotifier2D.connect("camera_entered", self, "on_camera_entered")

func on_camera_entered() -> void:
    if _can_spawn:
        var enemy: Node = _spawn_ref.instance()
        enemy.global_position = global_position
        for key in spawn_info:
            enemy.set(key, spawn_info[key])
        get_parent().add_child(enemy)
        enemy.connect("queued_free", self, "on_queued_free")
        _can_spawn = false

func on_queued_free() -> void:
    _can_spawn = true

func set_packed_scene_ref(value: PackedScene) -> void:
    packed_scene_ref = value
    if Engine.editor_hint and packed_scene_ref:
        add_child((load(packed_scene_ref.get_path()).instance()).get_node("Sprite").duplicate())
