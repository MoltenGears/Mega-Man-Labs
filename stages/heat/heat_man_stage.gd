extends Stage

onready var _music: Node

func _notification(what):
    # Temporary workaround until the following engine issue will be fixed.
    # https://github.com/godotengine/godot/issues/33620
    # Order of onready variables in sub-classes is broken.
    match what:
        NOTIFICATION_INSTANCED:
            _music = $Music

func _ready() -> void:
    if Global.lighting_vfx:
        for tilemap in get_tree().get_nodes_in_group("TileMaps"):
            if tilemap.name == "Lava":
                tilemap.modulate = Color(1.7, 1, 1, 1)

func _connect_signals() -> void:
    ._connect_signals()

    # Music
    _try_connect(self, "restarted", _music, "on_restarted")
    _try_connect(_gui_pause, "game_paused", _music, "on_game_paused")
    _try_connect(_gui_pause, "game_resumed", _music, "on_game_resumed")
    _try_connect(player, "died", _music, "on_died")
