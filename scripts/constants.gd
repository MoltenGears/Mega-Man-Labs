extends Node

# Game base sizes.
const WIDTH: int = 256
const HEIGHT: int = 224
const WIDTH_WIDE: int = 384
const HEIGHT_WIDE: int = 240
const TILE_SIZE := Vector2(16, 16)

# Common/Classic
const GRAVITY: float = 15.0
const FALL_SPEED_MAX: float = 420.0
const WALK_SPEED: float = 82.5
const STEP_SPEED: float = 60.0
const FLOOR_NORMAL := Vector2.UP
const PROJECTILE_SPEED: float = 300.0  # Experimental value.
const HIT_POINTS_MAX: int = 28
const CHARGE_DURATION_LVL1: float = 0.4
const CHARGE_DURATION_LVL2: float = 1.4

# Widescreen
const WALK_SPEED_WIDE: float = 110.0  # Mega Man 11 style.
const PROJECTILE_SPEED_WIDE: float = 384.0  # Mega Man 11 style.
