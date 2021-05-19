extends Sprite

# Implemented as separate script to be able to process this SpriteMask node
# while player itself is not processed when in pause mode.
# This is required during camera transitions in order to correctly update
# the mask sprites.

const ClimbMask: Resource = preload("res://characters/player/sprites/ClimbMask.png")
const IdleMask: Resource = preload("res://characters/player/sprites/IdleMask.png")
const IdleShootMask: Resource = preload("res://characters/player/sprites/IdleShootMask.png")
const JumpMask: Resource = preload("res://characters/player/sprites/JumpMask.png")
const JumpShootMask: Resource = preload("res://characters/player/sprites/JumpShootMask.png")
const RunMask: Resource = preload("res://characters/player/sprites/RunMask.png")
const RunShootMask: Resource = preload("res://characters/player/sprites/RunShootMask.png")
const SlideMask: Resource = preload("res://characters/player/sprites/SlideMask.png")
const SpawnMask: Resource = preload("res://characters/player/sprites/SpawnMask.png")
const StaggerMask: Resource = preload("res://characters/player/sprites/StaggerMask.png")

var _mask_textures: Dictionary = {
    "res://characters/player/sprites/Climb.png": ClimbMask,
    "res://characters/player/sprites/Idle.png": IdleMask,
    "res://characters/player/sprites/IdleShoot.png": IdleShootMask,
    "res://characters/player/sprites/Jump.png": JumpMask,
    "res://characters/player/sprites/JumpShoot.png": JumpShootMask,
    "res://characters/player/sprites/Run.png": RunMask,
    "res://characters/player/sprites/RunShoot.png": RunShootMask,
    "res://characters/player/sprites/Slide.png": SlideMask,
    "res://characters/player/sprites/Spawn.png": SpawnMask,
    "res://characters/player/sprites/Stagger.png": StaggerMask
}

onready var _sprite: Sprite = $"../Sprite"

func _ready() -> void:
    visible = true

func _physics_process(_delta: float) -> void:
    position = _sprite.position
    offset = _sprite.offset
    flip_h = _sprite.flip_h
    flip_v = _sprite.flip_v
    hframes = _sprite.hframes
    vframes = _sprite.vframes
    frame = _sprite.frame
    texture = _mask_textures[_sprite.texture.resource_path]
