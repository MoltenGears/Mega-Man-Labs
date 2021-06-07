extends Camera2D

const RAYCAST_LENGTH: int = 100000
const RAYCAST_OFFSET: int = 36

export(NodePath) var player_target_node
export(float) var transition_time := 1.0

var camera_target: Node2D
var _transition_pos: int
var _direction: Vector2

onready var _ray: RayCast2D = $TransitionFinder
onready var _base_width: int = Global.base_size.x
onready var _base_height: int = Global.base_size.y
onready var _death_distance: float = sqrt(pow(_base_width, 2) + pow(_base_height, 2)) / 1.5

signal transition_start()
signal transition_end()

func _ready() -> void:
    $CameraTween.connect("tween_completed", self, "_on_tween_completed")
    
    camera_target = get_node(player_target_node) as Node2D
    global_position = _get_target_pos()
    _set_multiplayer_boundaries_dimensions()
    init_limits()

func _physics_process(delta: float) -> void:
    for p in Global.players.values():
        if p.global_position.distance_to(get_camera_screen_center()) > _death_distance:
            p.die(false)

    global_position = _get_target_pos()
    $MultiplayerBoundaries.global_position = get_camera_screen_center()

func transition(dir: Vector2, transition: CameraTransition) -> void:
    if _get_transition_position(dir, true) == _ray.cast_to:
        transition.turn_on_wall()
        return
    
    emit_signal("transition_start")
    get_tree().paused = true
    set_physics_process(false)
    _direction = dir
    var old_cam_pos: Vector2 = get_camera_screen_center()
    _update_limit()    # Must be called before camera is set to top level
    set_as_toplevel(true)
    position = old_cam_pos

    var target_position: Vector2
    if _direction.x != 0:
        target_position = Vector2(_transition_pos + _base_width / 2 * _direction.x, position.y)
    else:
        target_position = Vector2(position.x, _transition_pos + _base_height / 2 * _direction.y)
                
    $CameraTween.interpolate_property(self, 'position',
            position,
            target_position,
            transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    $CameraTween.start()

    for p in Global.players.values():
        if not p.is_dead:
            var player_movement: Vector2
            var player_collision_extents: Vector2 = p.get_node("CollisionShape2D").shape.extents
            if _direction.x != 0:
                player_movement = player_collision_extents.x * 2.5 * _direction + \
                Vector2(_transition_pos - p.global_position.x, 0) * 1.6
            else:
                player_movement = player_collision_extents.y * 2 * _direction + \
                Vector2(0, _transition_pos - p.global_position.y) * 1.6
        
            $PlayerTween.interpolate_property(p, 'global_position',
                    p.global_position,
                    p.global_position + player_movement,
                    transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
            $PlayerTween.start()

func on_restarted() -> void:
    for p in Global.players.values():
        if not is_connected("transition_start", p, "on_camera_transition_start"):
            connect("transition_start", p, "on_camera_transition_start")
        if not is_connected("transition_end", p, "on_camera_transition_end"):
            connect("transition_end", p, "on_camera_transition_end")
    
    global_position = _get_target_pos()
    init_limits()

func init_limits() -> void:
    limit_right = _get_transition_position(Vector2.RIGHT).x
    limit_left = _get_transition_position(Vector2.LEFT).x
    limit_top = _get_transition_position(Vector2.UP).y
    limit_bottom = _get_transition_position(Vector2.DOWN).y

func _on_tween_completed(object: Object, key: NodePath) -> void:
    init_limits()
    set_as_toplevel(false)
    global_position = _get_target_pos()
    get_tree().paused = false
    set_physics_process(true)
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

func _get_target_pos() -> Vector2:
    if Global.players_alive_count > 1:
        # There are no min/max constants. 1e6 is just a substitute for that.
        var most_left_pos: float = 1e6
        var most_right_pos: float = -1e6
        var most_up_pos: float = 1e6
        var most_down_pos: float = -1e6

        for p in Global.players.values():
            most_left_pos = min(most_left_pos, p.global_position.x)
            most_right_pos = max(most_right_pos, p.global_position.x)
            most_up_pos = min(most_up_pos, p.global_position.y)
            most_down_pos = max(most_down_pos, p.global_position.y)

        return Vector2((most_left_pos + most_right_pos) / 2, (most_up_pos + most_down_pos) / 2)
    else:
        return camera_target.global_position

func _set_multiplayer_boundaries_dimensions() -> void:
    var offset: int = 8
    var width: int = 4
    var x: float = Global.base_size.x
    var y: float = Global.base_size.y

    $MultiplayerBoundaries/CollisionShapeTop.shape.extents.x = x / 2
    $MultiplayerBoundaries/CollisionShapeTop.shape.extents.y = width
    $MultiplayerBoundaries/CollisionShapeTop.position.y = -y / 2 - offset

    $MultiplayerBoundaries/CollisionShapeLeft.shape.extents.x = width
    $MultiplayerBoundaries/CollisionShapeLeft.shape.extents.y = y / 2
    $MultiplayerBoundaries/CollisionShapeLeft.position.x = -x / 2 - offset

    $MultiplayerBoundaries/CollisionShapeRight.shape.extents.x = width
    $MultiplayerBoundaries/CollisionShapeRight.shape.extents.y = y / 2
    $MultiplayerBoundaries/CollisionShapeRight.position.x = x / 2 + offset
