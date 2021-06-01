extends Sprite

# Implemented as separate script to be able to process this SpriteMask node
# while player itself is not processed when in pause mode.
# This is required during camera transitions in order to correctly update
# the mask sprites.

const ClimbMask: Resource = preload("res://characters/player/sprites/mega_man/ClimbMask.png")
const IdleMask: Resource = preload("res://characters/player/sprites/mega_man/IdleMask.png")
const IdleShootMask: Resource = preload("res://characters/player/sprites/mega_man/IdleShootMask.png")
const IdleShootAltMask: Resource = preload("res://characters/player/sprites/mega_man/IdleShootAltMask.png")
const JumpMask: Resource = preload("res://characters/player/sprites/mega_man/JumpMask.png")
const JumpShootMask: Resource = preload("res://characters/player/sprites/mega_man/JumpShootMask.png")
const JumpShootAltMask: Resource = preload("res://characters/player/sprites/mega_man/JumpShootAltMask.png")
const RunMask: Resource = preload("res://characters/player/sprites/mega_man/RunMask.png")
const RunShootMask: Resource = preload("res://characters/player/sprites/mega_man/RunShootMask.png")
const RunShootAltMask: Resource = preload("res://characters/player/sprites/mega_man/RunShootAltMask.png")
const SlideMask: Resource = preload("res://characters/player/sprites/mega_man/SlideMask.png")
const SpawnMask: Resource = preload("res://characters/player/sprites/mega_man/SpawnMask.png")
const StaggerMask: Resource = preload("res://characters/player/sprites/mega_man/StaggerMask.png")

var _mask_textures: Dictionary = {
    "res://characters/player/sprites/mega_man/Climb.png": ClimbMask,
    "res://characters/player/sprites/mega_man/Idle.png": IdleMask,
    "res://characters/player/sprites/mega_man/IdleShoot.png": IdleShootMask,
    "res://characters/player/sprites/mega_man/IdleShootAlt.png": IdleShootAltMask,
    "res://characters/player/sprites/mega_man/Jump.png": JumpMask,
    "res://characters/player/sprites/mega_man/JumpShoot.png": JumpShootMask,
    "res://characters/player/sprites/mega_man/JumpShootAlt.png": JumpShootAltMask,
    "res://characters/player/sprites/mega_man/Run.png": RunMask,
    "res://characters/player/sprites/mega_man/RunShoot.png": RunShootMask,
    "res://characters/player/sprites/mega_man/RunShootAlt.png": RunShootAltMask,
    "res://characters/player/sprites/mega_man/Slide.png": SlideMask,
    "res://characters/player/sprites/mega_man/Spawn.png": SpawnMask,
    "res://characters/player/sprites/mega_man/Stagger.png": StaggerMask
}

onready var _sprite: Sprite = $"../Sprite"

func _ready() -> void:
    visible = true
    if Global.lighting_vfx:
        modulate = Color(1.1, 1.1, 1.1, 1)

func _physics_process(_delta: float) -> void:
    position = _sprite.position
    offset = _sprite.offset
    flip_h = _sprite.flip_h
    flip_v = _sprite.flip_v
    hframes = _sprite.hframes
    vframes = _sprite.vframes
    frame = _sprite.frame
    texture = _mask_textures[_sprite.texture.resource_path]
