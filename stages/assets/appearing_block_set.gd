tool
extends Node2D

export(int, 3, 10) var cycle_duration := 5
export(bool) var show_indices := false setget _show_indices

var _blocks: Array = []
var _current_index: int = 0
var _active := true

func _ready() -> void:
    _update_blocks_array()

    $Timer.connect("timeout", self, "_change_blocks")

    if not Engine.editor_hint:
        _show_indices(false)

func _get_configuration_warning() -> String:
    if _blocks.empty():
        return "Add Appearing Blocks for this Node to work properly."
    else:
        return ""

func set_active() -> void:
    if not _active:
        _active = true
        _current_index = 0
        $Timer.start()

func set_inactive() -> void:
    if _active:
        _active = false
        $Timer.stop()

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

func _show_indices(value: bool) -> void:
    _update_blocks_array()
    show_indices = value
    for block in _blocks:
        block.show_index = value

func _update_blocks_array() -> void:
    for child in get_children():
        if child is AppearingBlock:
            _blocks.append(child)
