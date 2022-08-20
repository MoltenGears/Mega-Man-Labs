extends Camera2D

export(NodePath) var player_target_node
export(float) var transition_time := 1.0

var active_section: Section setget _set_active_section

var _camera_target: Node2D
var _boundaries_collision_mask: int
var _switching_target: bool

onready var _base_width: int = Global.base_size.x
onready var _base_height: int = Global.base_size.y
onready var _death_distance: float = sqrt(pow(_base_width, 2) + pow(_base_height, 2)) / 1.5

signal transition_start()
signal transition_end()

func _ready() -> void:
    _camera_target = get_node(player_target_node) as Node2D
    global_position = _get_target_pos()
    _set_multiplayer_boundaries_dimensions()
    _boundaries_collision_mask = $MultiplayerBoundaries.collision_mask

func _physics_process(delta: float) -> void:
    for p in Global.players.values():
        if p.global_position.distance_to(get_camera_screen_center()) > _death_distance:
            p.die(false)

    if not _switching_target:
        global_position = _get_target_pos()
        $MultiplayerBoundaries.global_position = get_camera_screen_center()

func transition_section(section: Section) -> void:
    emit_signal("transition_start")
    get_tree().paused = true
    set_physics_process(false)
    var direction: Vector2 = section.transition_dir
    var old_cam_pos: Vector2 = get_camera_screen_center()
    
    limit_left = -10000
    limit_top = -10000
    limit_right = 10000
    limit_bottom = 10000

    var transition_pos: float

    if direction == Vector2.RIGHT:
        transition_pos = section.limit_left
    elif direction == Vector2.LEFT:
        transition_pos = section.limit_right
    elif direction == Vector2.UP:
        transition_pos = section.limit_bottom
    elif direction == Vector2.DOWN:
        transition_pos = section.limit_top

    set_as_toplevel(true)
    position = old_cam_pos
    $MultiplayerBoundaries.collision_mask = 0  # Prevent moving players.

    var target_position: Vector2
    if direction.x != 0:
        target_position = Vector2(transition_pos + _base_width / 2 * direction.x, position.y)
    else:
        target_position = Vector2(position.x, transition_pos + _base_height / 2 * direction.y)
                
    var tween: SceneTreeTween = create_tween()
    tween \
        .tween_property(self, "position", target_position, transition_time) \
        .set_trans(Tween.TRANS_LINEAR) \
        .set_ease(Tween.EASE_IN_OUT)

    for p in Global.players.values():
        if not p.is_dead:
            var player_movement: Vector2
            var player_collision_extents: Vector2 = p.get_node("CollisionShape2D").shape.extents
            if direction.x != 0:
                player_movement = player_collision_extents.x * 2.5 * direction + \
                Vector2(transition_pos - p.global_position.x, 0) * 1.6
            else:
                player_movement = player_collision_extents.y * 2 * direction + \
                Vector2(0, transition_pos - p.global_position.y) * 1.6
        
            tween \
                .parallel() \
                .tween_property(p, "global_position", player_movement, transition_time) \
                .as_relative() \
                .set_trans(Tween.TRANS_LINEAR) \
                .set_ease(Tween.EASE_IN_OUT)
        
    yield(tween, "finished")

    if section.seal_previous_section:
        active_section.sealed = true
        section.seal_previous_section = false

    _set_active_section(section)
    update_limits()
    set_as_toplevel(false)
    global_position = _get_target_pos()
    $MultiplayerBoundaries.collision_mask = _boundaries_collision_mask
    get_tree().paused = false
    set_physics_process(true)
    emit_signal("transition_end")

func on_restarted() -> void:
    for p in Global.players.values():
        if not is_connected("transition_start", p, "on_camera_transition_start"):
            connect("transition_start", p, "on_camera_transition_start")
        if not is_connected("transition_end", p, "on_camera_transition_end"):
            connect("transition_end", p, "on_camera_transition_end")
    
    global_position = _get_target_pos()

func on_died() -> void:
    if Global.players_alive_count > 0:
        _switching_target = true

func on_death_freeze_finished(dead_player: Node2D) -> void:
    if Global.players_alive_count < 1:
        return
    elif Global.players_alive_count == 1:
        for p in Global.players.values():
            if not p.is_dead:
                _camera_target = p
                break

    get_tree().paused = true
    $MultiplayerBoundaries.collision_mask = 0  # Prevent moving players.

    var tween: SceneTreeTween = create_tween()
    tween \
        .tween_property(self, "global_position", _get_target_pos(), 0.66) \
        .from(get_camera_screen_center()) \
        .set_trans(Tween.TRANS_QUAD) \
        .set_ease(Tween.EASE_IN_OUT)

    yield(tween, "finished")

    get_tree().paused = false
    $MultiplayerBoundaries.collision_mask = _boundaries_collision_mask
    _switching_target = false

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
        return _camera_target.global_position

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

func _set_active_section(value: Section) -> void:
    if active_section:
        active_section.active = false

        if not value:
            print("Cleared Active Section: %s" % active_section)
            active_section = null
            return

    active_section = value
    active_section.active = true
    update_limits()
    # print("New Active Section: ", value.name)

func update_limits() -> void:
    limit_left = active_section.limit_left
    limit_top = active_section.limit_top
    limit_right = active_section.limit_right
    limit_bottom = active_section.limit_bottom
