tool
extends Position2D

export(PackedScene) var packed_scene_ref: PackedScene setget set_packed_scene_ref

var _can_respawn := true
var spawn_count_max := -1
var spawn_timer := 0.0
var spawn_info := {}

onready var _spawn_ref: Resource

func _ready() -> void:
    if packed_scene_ref:
        _spawn_ref = load(packed_scene_ref.get_path())

    $PreciseVisibilityNotifier2D.connect("camera_entered", self, "on_camera_entered")

    if spawn_timer > 0.0:
        $Timer.connect("timeout", self, "_on_timeout")

func on_camera_entered() -> void:
    _spawn_enemy()
    if spawn_timer > 0.0:
        $Timer.start(spawn_timer)

func on_queued_free(enemy_name: String) -> void:
        GameState.decrease_enemy_count(enemy_name)
        _can_respawn = true

func set_packed_scene_ref(value: PackedScene) -> void:
    packed_scene_ref = value
    if Engine.editor_hint and packed_scene_ref:
        add_child((load(packed_scene_ref.get_path()).instance()).get_node("Sprite").duplicate())

func _spawn_enemy() -> void:
    if spawn_count_max < 0 and not _can_respawn:
        return

    var enemy: Node = _spawn_ref.instance()
    if spawn_count_max < 0 or GameState.get_enemy_count(enemy.enemy_name) < spawn_count_max:
        _can_respawn = false
        enemy.position = position
        for key in spawn_info:
            enemy.set(key, spawn_info[key])
        get_parent().add_child(enemy)
        enemy.connect("queued_free", self, "on_queued_free", [enemy.enemy_name])
        GameState.increase_enemy_count(enemy.enemy_name)

func _on_timeout():
    if $PreciseVisibilityNotifier2D.is_on_screen():
        _spawn_enemy()
