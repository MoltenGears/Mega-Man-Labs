extends Node

# Game base sizes.
const WIDTH: int = 256
const HEIGHT: int = 224
const WIDTH_WIDE: int = 512
const HEIGHT_WIDE: int = 288

# Common/Classic
const GRAVITY: float = 15.0
const FALL_SPEED_MAX: float = 420.0
const WALK_SPEED: float = 82.5
const STEP_SPEED: float = 60.0
const FLOOR_NORMAL := Vector2.UP
const PROJECTILE_COUNT_MAX: int = 3
const PROJECTILE_SPEED: float = 300.0  # Experimental value.
const HIT_POINTS_MAX: int = 28

# Widescreen
const WALK_SPEED_WIDE: float = 110.0
const PROJECTILE_SPEED_WIDE: float = 450.0  # Experimental value.
