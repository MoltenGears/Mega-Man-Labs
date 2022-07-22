extends State

onready var sprite: Sprite = get_node("../../Sprite")
onready var mega_buster: Position2D = get_node("../../MegaBusterPos")
onready var animation_player: AnimationPlayer = get_node("../../AnimationPlayer")
onready var weapons: Node = get_node("../../Weapons")
onready var inputs: InputHandler = get_node("../../Inputs")

func _handle_command(command: String) -> void:
    pass

func get_input_direction() -> Vector2:
    return get_parent().input_direction

# Returns true if direction changed.
func update_sprite_direction(direction: Vector2) -> bool:
    var last_facing_direction = owner.get_facing_direction()
    if direction.x == 1:
        sprite.flip_h = false
    elif direction.x == -1:
        sprite.flip_h = true
    sprite.offset.x = owner.get_facing_direction().x * abs(sprite.offset.x)
    return last_facing_direction != owner.get_facing_direction()

func shoot() -> void:
    owner.buffering_charge = false
    weapons.current_state.use()
