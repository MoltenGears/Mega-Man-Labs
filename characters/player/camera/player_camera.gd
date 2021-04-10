extends Camera2D

const RAYCAST_LENGTH: int = 100000
const RAYCAST_OFFSET: int = 32

export(NodePath) var player_target_node
export(float) var transition_time := 1.0

var _transition_pos: int
var _direction: Vector2

onready var _player: Node2D = get_node(player_target_node) as Node2D
onready var _player_collision_extents: Vector2 = _player.get_node("CollisionShape2D").shape.extents
onready var _ray: RayCast2D = $TransitionFinder
onready var _base_width: int = Global.base_size.x
onready var _base_height: int = Global.base_size.y
onready var _death_distance: float = sqrt(pow(_base_width, 2) + pow(_base_height, 2)) / 1.5

signal transition_start()
signal transition_end()

func _ready() -> void:
    $CameraTween.connect("tween_completed", self, "_on_tween_completed")
    connect("transition_start", _player, "on_camera_transition_start")
    connect("transition_end", _player, "on_camera_transition_end")
    global_position = _player.global_position
    init_limits()

func _physics_process(delta: float) -> void:
    if _player.global_position.distance_to(get_camera_screen_center()) > _death_distance:
        _player.die(false)

    position = _player.position

func transition(dir: Vector2, transition: CameraTransition) -> void:
    if _get_transition_position(dir, true) == _ray.cast_to:
        transition.turn_on_wall()
        return
    
    emit_signal("transition_start")
    get_tree().paused = true
    _direction = dir
    var old_cam_pos: Vector2 = get_camera_screen_center()
    _update_limit()    # Must be called before camera is set to top level
    set_as_toplevel(true)
    position = old_cam_pos

    var target_position: Vector2
    var player_movement: Vector2
    if _direction.x != 0:
        target_position = Vector2(_transition_pos + _base_width / 2 * _direction.x, position.y)
        player_movement = _player_collision_extents.x * 2.5 * _direction + \
                Vector2(_transition_pos - _player.global_position.x, 0) * 1.6
    else:
        target_position = Vector2(position.x, _transition_pos + _base_height / 2 * _direction.y)
        player_movement = _player_collision_extents.y * 2 * _direction + \
                Vector2(0, _transition_pos - _player.global_position.y) * 1.6
                
    $CameraTween.interpolate_property(self, 'position',
            position,
            target_position,
            transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    $CameraTween.start()

    $PlayerTween.interpolate_property(_player, 'global_position',
            _player.global_position,
            _player.global_position + player_movement,
            transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    $PlayerTween.start()

func on_restarted() -> void:
    global_position = _player.global_position
    init_limits()

func init_limits() -> void:
    limit_right = _get_transition_position(Vector2.RIGHT).x
    limit_left = _get_transition_position(Vector2.LEFT).x
    limit_top = _get_transition_position(Vector2.UP).y
    limit_bottom = _get_transition_position(Vector2.DOWN).y

func _on_tween_completed(object: Object, key: NodePath) -> void:
    init_limits()
    set_as_toplevel(false)
    global_position = _player.global_position
    get_tree().paused = false
    emit_signal("transition_end")

func _update_limit() -> void:
    if _direction == Vector2.RIGHT:
        _transition_pos = limit_right
        limit_right = _get_transition_position(_direction, true).x
    elif _direction == Vector2.LEFT:
        _transition_pos = limit_left
        limit_left = _get_transition_position(_direction, true).x
    elif _direction == Vector2.UP:
        _transition_pos = limit_top
        limit_top = _get_transition_position(_direction, true).y
    elif _direction == Vector2.DOWN:
        _transition_pos = limit_bottom
        limit_bottom = _get_transition_position(_direction, true).y

# Returns the closest camera transition area position in the set direction.
# Optionally centers the other axis of the ray cast on the camera screen center,
# e.g., ray casting in x-direction would be centered on the y-position
# of the camera screen center.
func _get_transition_position(dir: Vector2, on_camera_screen_center := false) -> Vector2:
    if dir.x != 0 and on_camera_screen_center:
        _ray.global_position.y = get_camera_screen_center().y
    elif dir.y != 0 and on_camera_screen_center:
        _ray.global_position.x = get_camera_screen_center().x
    _ray.position += dir * RAYCAST_OFFSET
    _ray.cast_to = dir * RAYCAST_LENGTH
    _ray.force_raycast_update()
    _ray.position = Vector2()
    if _ray.is_colliding():
        return _ray.get_collider().global_position
    else:
        return _ray.cast_to
