extends "common.gd"

func _handle_command(command: String) -> void:
    if command == "slide" and owner.can_slide:
        emit_signal("finished", "slide")
    elif command == "jump":
        emit_signal("finished", "jump")
    else:
        ._handle_command(command)
