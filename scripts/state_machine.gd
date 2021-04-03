# Based on Nathan Lovato's tutorial:
# https://github.com/GDquest/Godot-engine-tutorial-demos/blob/master/2018/04-24-finite-state-machine/player_v2/state_machine.gd

extends Node

# Base class for a state machine.
class_name StateMachine

export(NodePath) var start_state: NodePath

var states_map := {}
var states_stack := []
var current_state: Node = null
var active := false setget set_active

signal state_changed(current_state)

func _ready() -> void:
    for state in get_children():
        state.connect("finished", self, "_change_state")
    initialize(start_state)

func initialize(state: NodePath) -> void:
    set_active(true)
    states_stack = []
    states_stack.push_front(get_node(state))
    current_state = states_stack[0]
    current_state._enter()

func set_active(value: bool) -> void:
    active = value
    set_physics_process(value)
    set_process_input(value)
    if not active:
        states_stack = []
        current_state = null

func _unhandled_input(event: InputEvent) -> void:
    if current_state:
        current_state._handle_input(event)

func _physics_process(delta: float) -> void:
    current_state._update(delta)

func _on_animation_finished(anim_name: String) -> void:
    if active:
        current_state._on_animation_finished(anim_name)

func _change_state(state_name: String) -> void:
    if not active:
        return
        
    current_state._exit()
    
    if state_name == "previous":
        states_stack.pop_front()
    else:
        states_stack[0] = states_map[state_name]
    
    current_state = states_stack[0]
    emit_signal("state_changed", current_state)
    
    if state_name != "previous":
        current_state._enter()
