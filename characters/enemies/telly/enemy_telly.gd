extends "res://characters/enemies/base/enemy_base.gd"

func _ready() -> void:
    $Inputs.controller = InputHandler.Controller.AI
    $Inputs.ai = $AI
