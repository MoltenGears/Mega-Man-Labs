extends Control

func _ready() -> void:
    set_process(false)
    visible = false
    $Timer.connect("timeout", self, "_on_timeout")

func _process(delta: float) -> void:
    rect_position = Global.player.get_global_transform_with_canvas().origin

func on_weapon_changed(_weapon_energy: int, _new_color: Color) -> void:
    if _set_texture() and not Global.in_pause_menu:
        set_process(true)
        visible = true
        $Timer.start()
        $TextureRect.use_parent_material = Global.player.name != "ProtoMan"

func _set_texture() -> bool:
    var texture: Resource
    match Global.player.get_current_weapon_name():
        "mega_buster":
            texture = load("res://gui/textures/WeaponIconMegaBuster.png")
        "electric_ball":
            texture = load("res://gui/textures/WeaponIconElectricBall.png")

    if texture:
        $TextureRect.texture = texture
        return true
    else:
        return false

func _on_timeout() -> void:
    visible = false
    set_process(false)
