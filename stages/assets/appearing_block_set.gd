tool
extends Node2D

export(int, 3, 10) var cycle_duration := 5

var _blocks: Array = []
var _current_index: int = 0
var _active := true

func _ready() -> void:
    for child in get_children():
        if child is AppearingBlock:
            _blocks.append(child)

    $Timer.connect("timeout", self, "_change_blocks")

func _get_configuration_warning() -> String:
    if _blocks.empty():
        return "Add Appearing Blocks for this Node to work properly."
    else:
        return ""

func set_active() -> void:
    if not _active:
        _active = true
        _current_index = 1
        $Timer.start()
        print("Set ACTIVE")

func set_inactive() -> void:
    if _active:
        _active = false
        $Timer.stop()
        print("Set INACTIVE")

func _change_blocks() -> void:
    var play_sound := false
    var any_block_on_screen := false

    for block in _blocks:
        any_block_on_screen = any_block_on_screen or block.is_on_screen()

        if (block.index == _current_index):
            block.appear()

            if block.is_on_screen():
                play_sound = true

    if not any_block_on_screen:
        set_inactive()

    if play_sound:
        $Sound.play()

    if _current_index < cycle_duration:
        _current_index += 1
    else:
        _current_index = 1
