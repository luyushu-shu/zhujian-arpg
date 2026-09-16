extends Node2D
## 分件骨骼：髋—大腿—小腿—脚 + 剑，走跑踢迈步，挥砍分起手/出招/收势。

@export var kind: String = "hero"

var walk_phase := 0.0
var idle_t := 0.0


func _ready() -> void:
	if kind == "foe":
		_build_foe()
	else:
		_build_hero()


func part(pts: Array, color: Color, z := 0, parent: Node = self) -> Polygon2D:
	var p := Polygon2D.new()
	var packed := PackedVector2Array()
	for v in pts:
		packed.append(v as Vector2)
	p.polygon = packed
	p.color = color
	p.z_index = z
	parent.add_child(p)
	return p


func bone(bone_name: String, pos: Vector2, parent: Node = self) -> Node2D:
	var n := Node2D.new()
	n.name = bone_name
	n.position = pos
	parent.add_child(n)
	return n


func _add_leg(hip: Node2D, leg_name: String, x: float, thigh_c: Color, shin_c: Color, boot: Color) -> void:
	var thigh := bone(leg_name, Vector2(x, 0), hip)
	part([Vector2(-6.5, -1), Vector2(5.5, -1), Vector2(6.2, 12), Vector2(-7.2, 12)], thigh_c, 1, thigh)
	var shin := bone("Shin", Vector2(0, 11), thigh)
	part([Vector2(-4.2, 0), Vector2(4.0, 0), Vector2(4.6, 9.5), Vector2(-4.8, 9.5)], shin_c, 1, shin)
	var foot := bone("Foot", Vector2(0, 9), shin)
	part([Vector2(-3.2, -1.6), Vector2(10.5, 0.2), Vector2(10.2, 4.8), Vector2(-3.8, 3.6)], boot, 2, foot)
	part([Vector2(-2.8, -6), Vector2(3.6, -5), Vector2(4.2, 1), Vector2(-3.2, 1)], shin_c, 2, foot)


func _ink(v: float, a: float = 1.0) -> Color:
	return Color(v, v, v * 1.02, a)


func _build_hero() -> void:
	var ink := _ink(0.07)
	var ink2 := _ink(0.13)
	var ink3 := _ink(0.20)
	var ink4 := _ink(0.28)
	var boot := _ink(0.05)
	var edge := Color(0.42, 0.42, 0.44, 1)

	var splash := bone("InkSplash", Vector2(0, 2))
	part([Vector2(-26, 1), Vector2(-10, -5), Vector2(8, -2), Vector2(24, 3), Vector2(18, 8), Vector2(-14, 9)], _ink(0.06, 0.4), -3, splash)
	part([Vector2(-18, 3), Vector2(-4, -1), Vector2(14, 4), Vector2(6, 7), Vector2(-8, 7)], _ink(0.04, 0.28), -2, splash)

	var hip := bone("Hip", Vector2(0, -20))
	_add_leg(hip, "LegL", -5.0, ink2, ink3, boot)
	_add_leg(hip, "LegR", 5.0, ink2, ink3, boot)
	part([Vector2(-16, -2), Vector2(15, -2), Vector2(20, 14), Vector2(8, 18), Vector2(-6, 18), Vector2(-20, 13)], ink, 2, hip)
	part([Vector2(-8, 4), Vector2(10, 6), Vector2(14, 16), Vector2(-4, 17)], ink2, 3, hip)

	var torso := bone("Torso", Vector2(0, -20))
	var cape := bone("Cape", Vector2(-3, -10), torso)
	part([Vector2(-6, -4), Vector2(8, 0), Vector2(28, 8), Vector2(36, 22), Vector2(18, 28), Vector2(-2, 16), Vector2(-14, 6)], ink, 0, cape)
	part([Vector2(4, 2), Vector2(22, 10), Vector2(30, 20), Vector2(16, 24), Vector2(2, 12)], ink2, 1, cape)
	part([Vector2(16, 6), Vector2(34, 4), Vector2(42, 14), Vector2(24, 18)], _ink(0.1, 0.85), 0, cape)

	part([Vector2(-11, 1), Vector2(11, 1), Vector2(10, -17), Vector2(-10, -17)], ink2, 3, torso)
	part([Vector2(-12, -1), Vector2(12, -1), Vector2(11, 4), Vector2(-13, 5)], ink, 4, torso)
	part([Vector2(-18, -12), Vector2(-6, -10), Vector2(-8, 6), Vector2(-22, 4)], ink, 2, torso)
	part([Vector2(6, -11), Vector2(16, -8), Vector2(20, 5), Vector2(8, 4)], ink3, 2, torso)
	part([Vector2(-7, -15), Vector2(7, -15), Vector2(6, -19), Vector2(-6, -19)], ink4, 4, torso)

	var head := bone("Head", Vector2(0, -18), torso)
	part([Vector2(-6.5, 5), Vector2(6.5, 5), Vector2(7, -2), Vector2(-7, -3)], ink, 5, head)
	part([Vector2(-6, 2), Vector2(6, 2), Vector2(6, 6), Vector2(-6, 6)], ink2, 6, head)

	var hat := bone("Hat", Vector2(0, -5), head)
	part([Vector2(-20, 3), Vector2(20, 4), Vector2(16, -2), Vector2(0, -5), Vector2(-16, -3)], ink, 8, hat)
	part([Vector2(-8, -1), Vector2(8, 0), Vector2(5, -8), Vector2(-6, -9)], ink2, 9, hat)
	part([Vector2(-19, 2.2), Vector2(19, 3.2), Vector2(18, 4.6), Vector2(-18, 3.8)], _ink(0.04), 10, hat)
	var ribbon := bone("Ribbon", Vector2(12, -2), hat)
	part([Vector2(0, -2), Vector2(10, -6), Vector2(22, -4), Vector2(18, 2), Vector2(6, 3)], ink3, 7, ribbon)
	part([Vector2(8, -4), Vector2(20, -10), Vector2(28, -6), Vector2(16, 0)], ink, 6, ribbon)

	var sword := bone("Sword", _sword_rest(), torso)
	sword.rotation_degrees = 82
	part([Vector2(-8, -2.4), Vector2(5, -2.2), Vector2(5, 2.2), Vector2(-8, 2.4)], _ink(0.09), 8, sword)
	part([Vector2(2, -7), Vector2(7, -7), Vector2(7, 7), Vector2(2, 7)], ink4, 9, sword)
	part([Vector2(6, -3.2), Vector2(34, -4.2), Vector2(39, 0), Vector2(34, 4.2), Vector2(6, 3.2)], ink3, 8, sword)
	part([Vector2(20, -2.4), Vector2(36, -3.2), Vector2(38, 0), Vector2(34, 1.2)], edge, 9, sword)
	part([Vector2(-3, -4), Vector2(7, -3), Vector2(7, 3), Vector2(-3, 4)], ink, 7, sword)


func _build_foe() -> void:
	var cloth := _ink(0.16)
	var cloth_d := _ink(0.11)
	var wrap := Color(0.22, 0.18, 0.16, 1)
	var boot := _ink(0.08)
	var iron := _ink(0.32)

	var hip := bone("Hip", Vector2(0, -19))
	_add_leg(hip, "LegL", -5.0, cloth_d, cloth, boot)
	_add_leg(hip, "LegR", 5.0, cloth_d, cloth, boot)
	part([Vector2(-13, 0), Vector2(13, 0), Vector2(16, 13), Vector2(6, 16), Vector2(-6, 16), Vector2(-16, 12)], cloth, 2, hip)

	var torso := bone("Torso", Vector2(0, -19))
	var cape := bone("Cape", Vector2(-2, -8), torso)
	part([Vector2(-4, -2), Vector2(6, 2), Vector2(18, 14), Vector2(8, 18), Vector2(-8, 8)], cloth_d, 0, cape)
	part([Vector2(-9, 0), Vector2(9, 0), Vector2(8, -16), Vector2(-8, -16)], cloth, 3, torso)
	part([Vector2(-10, -1), Vector2(10, -1), Vector2(10, 3), Vector2(-10, 3)], wrap, 4, torso)
	part([Vector2(-16, -10), Vector2(-5, -8), Vector2(-7, 3), Vector2(-18, 1)], cloth_d, 2, torso)

	var head := bone("Head", Vector2(0, -16), torso)
	part([Vector2(-7, 4), Vector2(7, 4), Vector2(8, -4), Vector2(0, -11), Vector2(-8, -4)], cloth_d, 5, head)
	part([Vector2(-5, 1), Vector2(5, 1), Vector2(5, 5), Vector2(-5, 5)], cloth, 6, head)
	part([Vector2(-6, -2), Vector2(6, -2), Vector2(6, -6), Vector2(-6, -6)], wrap, 7, head)

	var sword := bone("Sword", _sword_rest(), torso)
	sword.rotation_degrees = 22
	part([Vector2(-8, -2.4), Vector2(4, -2.4), Vector2(4, 2.4), Vector2(-8, 2.4)], _ink(0.12), 8, sword)
	part([Vector2(1, -7), Vector2(6, -7), Vector2(6, 7), Vector2(1, 7)], iron, 9, sword)
	part([Vector2(5, -5), Vector2(28, -6), Vector2(31, 0), Vector2(28, 6), Vector2(5, 5)], iron, 8, sword)
	part([Vector2(-2, -4), Vector2(7, -3), Vector2(7, 3), Vector2(-2, 4)], cloth, 7, sword)


func sword_node() -> Node2D:
	return get_node_or_null("Torso/Sword") as Node2D


func _sword_rest() -> Vector2:
	return Vector2(4, -3) if kind == "hero" else Vector2(7, -8)


func _hip_base_y() -> float:
	return -20.0 if kind == "hero" else -19.0


func reset_modulate() -> void:
	modulate = Color.WHITE


func _flow(cape_rot: float, ribbon_rot: float, splash: bool = true) -> void:
	var cape := get_node_or_null("Torso/Cape") as Node2D
	if cape:
		cape.rotation = cape_rot
	var ribbon := get_node_or_null("Torso/Head/Hat/Ribbon") as Node2D
	if ribbon:
		ribbon.rotation = ribbon_rot
	var splash_n := get_node_or_null("InkSplash") as Node2D
	if splash_n:
		splash_n.visible = splash
		splash_n.rotation = cape_rot * 0.15


func _span(t: float, a: float, b: float) -> float:
	return clampf((t - a) / maxf(b - a, 0.0001), 0.0, 1.0)


func play_idle(delta: float = 0.0) -> void:
	walk_phase = 0.0
	idle_t += delta
	var breath: float = sin(idle_t * 2.4) * 0.8
	var shift: float = sin(idle_t * 1.1) * 0.04
	var wind: float = sin(idle_t * 1.7)
	_hip(shift * 0.12, breath * 0.2)
	_leg("LegL", 0.08 + shift, 0.22, -0.08, 0.0)
	_leg("LegR", -0.05 - shift, 0.16, -0.06, 0.0)
	_torso(0.04, breath)
	_head(-0.02)
	_flow(-0.22 + wind * 0.10, 0.15 + wind * 0.22, true)
	# 站立：剑垂于身侧，刃尖朝下
	_sword(94.0 + wind * 4.0, Vector2(2.5, 3.0) + Vector2(wind * 0.3, breath * 0.12))
	reset_modulate()


func play_loco(delta: float, speed_ratio: float, running: bool) -> void:
	var cadence: float = lerpf(9.2, 15.5, speed_ratio)
	if running:
		cadence = 17.2
	walk_phase += delta * cadence
	var ph: float = walk_phase
	var sl: float = sin(ph)
	var sr: float = sin(ph + PI)
	var cl: float = cos(ph)
	var swing_l: float = maxf(0.0, sl)
	var swing_r: float = maxf(0.0, sr)
	var plant_l: float = maxf(0.0, -sl)
	var plant_r: float = maxf(0.0, -sr)
	var th_amp: float = 0.78 if running else 0.46
	var kn_amp: float = 1.05 if running else 0.62
	var lift_amp: float = -5.2 if running else -2.6
	_leg(
		"LegL",
		sl * th_amp,
		0.10 + swing_l * kn_amp + plant_l * 0.22,
		-0.12 - swing_l * 0.35 + plant_l * 0.18,
		swing_l * lift_amp
	)
	_leg(
		"LegR",
		sr * th_amp,
		0.10 + swing_r * kn_amp + plant_r * 0.22,
		-0.12 - swing_r * 0.35 + plant_r * 0.18,
		swing_r * lift_amp
	)
	var bob: float = absf(cl) * (3.2 if running else 1.45)
	_hip(sl * (0.08 if running else 0.04), bob)
	_torso(sl * (0.12 if running else 0.055) + (0.14 if running else 0.02), bob * 0.35)
	_head(-sl * 0.07)
	_flow((-0.58 if running else -0.34) + sl * 0.14, sl * 0.4, true)
	if running:
		# 奔跑：拖刀，剑身贴后、刃尖朝后
		_sword(148.0 + sl * 10.0, Vector2(-3.0 + sl * 1.2, -5.0) + Vector2(0.0, -absf(sl) * 1.2))
	else:
		# 行走：斜提剑，剑尖略向前下，与步伐对摆
		_sword(32.0 + sl * 14.0, Vector2(11.0, -9.0) + Vector2(sl * 2.4, cl * 1.1))
	reset_modulate()


func play_jump() -> void:
	_hip(0.0, -3.0)
	_leg("LegL", -0.55, 0.85, 0.1, -2.0)
	_leg("LegR", 0.35, 0.25, -0.2, 0.0)
	_torso(-0.12, -4.0)
	_head(-0.08)
	# 起跳：收剑贴肩，刃尖朝上
	_sword(-42.0, Vector2(1.0, -16.0))
	_flow(-0.7, 0.45, false)
	reset_modulate()


func play_fall() -> void:
	_hip(0.0, 1.0)
	_leg("LegL", 0.25, 0.2, 0.15, 0.0)
	_leg("LegR", -0.65, 1.05, 0.2, -1.5)
	_torso(0.18, 2.0)
	_head(0.12)
	# 下落：剑尖朝下，准备落地
	_sword(78.0, Vector2(7.0, 1.0))
	_flow(-0.85, 0.55, false)
	reset_modulate()


func play_land(t: float) -> void:
	var k: float = 1.0 - clampf(t, 0.0, 1.0)
	_hip(0.0, 4.0 * k)
	_leg("LegL", -0.35 * k, 0.7 * k + 0.15, 0.05, 0.0)
	_leg("LegR", 0.2 * k, 0.55 * k + 0.15, 0.0, 0.0)
	_torso(0.22 * k, 5.0 * k)
	_head(0.1 * k)
	_sword(lerpf(78.0, 94.0, t), Vector2(3.0, 2.0))
	_flow(-0.2, 0.1, true)
	reset_modulate()


func play_crouch() -> void:
	_hip(0.0, 6.0)
	_leg("LegL", -0.55, 1.15, 0.15, 0.0)
	_leg("LegR", 0.45, 1.05, 0.1, 0.0)
	_torso(0.18, 9.0)
	_head(0.08)
	# 下蹲：横剑护膝
	_sword(108.0, Vector2(8.0, 6.0))
	_flow(-0.15, 0.2, true)
	reset_modulate()


func play_slide(t: float) -> void:
	var k: float = sin(clampf(t, 0.0, 1.0) * PI)
	_hip(0.35, 8.0)
	_leg("LegL", -1.05, 0.35, 0.4, 0.0)
	_leg("LegR", 0.55, 0.9, 0.2, 1.0)
	_torso(0.85, 11.0)
	_head(0.25)
	# 滑行：剑贴地横拖，刃尖朝后
	_sword(172.0 + k * 8.0, Vector2(10.0, 11.0) + Vector2(k * 3.0, 0.0))
	_flow(-0.9, 0.5, false)
	modulate = Color(0.92, 0.92, 0.95)


func play_attack(combo_step: int, lock_left: float, lock_total: float) -> void:
	var t: float = 1.0 - clampf(lock_left / maxf(lock_total, 0.01), 0.0, 1.0)
	if combo_step <= 1:
		_slash_down(t)
	elif combo_step == 2:
		_slash_up(t)
	else:
		_slash_thrust(t)
	modulate = Color(1.12, 1.12, 1.14)


func _slash_down(t: float) -> void:
	var deg: float
	var pos: Vector2
	if t < 0.30:
		var u: float = ease(_span(t, 0.0, 0.30), 0.4)
		deg = lerpf(22.0, 108.0, u)
		pos = _sword_rest().lerp(Vector2(1, -20), u)
		_hip(0.06, 1.0 * u)
		_leg("LegL", lerpf(0.05, -0.35, u), 0.35, 0.0, 0.0)
		_leg("LegR", lerpf(0.0, 0.28, u), 0.2, -0.05, 0.0)
		_torso(lerpf(0.04, 0.32, u), -1.0)
		_head(0.12)
	elif t < 0.58:
		var u: float = ease(_span(t, 0.30, 0.58), 2.6)
		deg = lerpf(108.0, -98.0, u)
		pos = Vector2(1, -20).lerp(Vector2(18, 6), u)
		_hip(-0.08, 2.0)
		_leg("LegL", lerpf(-0.35, 0.15, u), 0.25, 0.0, 0.0)
		_leg("LegR", lerpf(0.28, 0.55, u), 0.15, -0.1, 0.0)
		_torso(lerpf(0.32, -0.38, u), 1.5)
		_head(-0.08)
	else:
		var u: float = ease(_span(t, 0.58, 1.0), 0.35)
		deg = lerpf(-98.0, -28.0, u)
		pos = Vector2(18, 6).lerp(Vector2(10, -2), u)
		_hip(0.0, 0.5)
		_leg("LegL", 0.1, 0.22, 0.0, 0.0)
		_leg("LegR", 0.4, 0.18, -0.05, 0.0)
		_torso(lerpf(-0.38, -0.12, u), 0.0)
		_head(0.02)
	_flow(-0.55, 0.35, false)
	_sword(deg, pos)


func _slash_up(t: float) -> void:
	var deg: float
	var pos: Vector2
	if t < 0.28:
		var u: float = ease(_span(t, 0.0, 0.28), 0.4)
		deg = lerpf(-20.0, -78.0, u)
		pos = _sword_rest().lerp(Vector2(10, 8), u)
		_hip(-0.05, 1.5)
		_leg("LegL", 0.2, 0.2, 0.0, 0.0)
		_leg("LegR", -0.25, 0.4, 0.1, 0.0)
		_torso(lerpf(-0.1, 0.22, u), 1.0)
		_head(-0.1)
	elif t < 0.60:
		var u: float = ease(_span(t, 0.28, 0.60), 2.4)
		deg = lerpf(-78.0, 118.0, u)
		pos = Vector2(10, 8).lerp(Vector2(8, -18), u)
		_hip(0.1, 0.0)
		_leg("LegL", lerpf(0.2, -0.4, u), 0.3, 0.0, -1.0)
		_leg("LegR", lerpf(-0.25, 0.45, u), 0.15, 0.0, 0.0)
		_torso(lerpf(0.22, -0.28, u), -1.0)
		_head(0.12)
	else:
		var u: float = ease(_span(t, 0.60, 1.0), 0.4)
		deg = lerpf(118.0, 42.0, u)
		pos = Vector2(8, -18).lerp(Vector2(8, -8), u)
		_hip(0.0, 0.0)
		_leg("LegL", -0.2, 0.25, 0.0, 0.0)
		_leg("LegR", 0.3, 0.18, 0.0, 0.0)
		_torso(lerpf(-0.28, -0.05, u), 0.0)
		_head(0.04)
	_flow(-0.55, 0.35, false)
	_sword(deg, pos)


func _slash_thrust(t: float) -> void:
	var deg: float
	var pos: Vector2
	if t < 0.34:
		var u: float = ease(_span(t, 0.0, 0.34), 0.5)
		deg = lerpf(20.0, 8.0, u)
		pos = _sword_rest().lerp(Vector2(-4, -9), u)
		_hip(-0.04, 0.0)
		_leg("LegL", 0.45, 0.55, 0.1, 0.0)
		_leg("LegR", -0.35, 0.25, 0.0, 0.0)
		_torso(0.08, 0.0)
		_head(-0.06)
	elif t < 0.62:
		var u: float = ease(_span(t, 0.34, 0.62), 2.8)
		deg = lerpf(8.0, 2.0, u)
		pos = Vector2(-4, -9).lerp(Vector2(24, -11), u)
		_hip(0.0, 0.0)
		_leg("LegL", lerpf(0.45, 0.15, u), 0.2, 0.0, 0.0)
		_leg("LegR", lerpf(-0.35, 0.55, u), 0.12, -0.08, 0.0)
		_torso(-0.12, 0.0)
		_head(0.04)
	else:
		var u: float = ease(_span(t, 0.62, 1.0), 0.35)
		deg = 6.0
		pos = Vector2(24, -11).lerp(Vector2(14, -10), u)
		_hip(0.0, 0.0)
		_leg("LegL", 0.1, 0.2, 0.0, 0.0)
		_leg("LegR", 0.4, 0.15, 0.0, 0.0)
		_torso(-0.06, 0.0)
		_head(0.0)
	_flow(-0.55, 0.35, false)
	_sword(deg, pos)


func play_air_slash(lock_left: float, lock_total: float) -> void:
	var t: float = 1.0 - clampf(lock_left / maxf(lock_total, 0.01), 0.0, 1.0)
	var deg: float
	var pos: Vector2
	if t < 0.4:
		var u: float = ease(_span(t, 0.0, 0.4), 2.2)
		deg = lerpf(-25.0, 170.0, u)
		pos = _sword_rest().lerp(Vector2(4, -16), u)
	else:
		var u: float = ease(_span(t, 0.4, 1.0), 0.45)
		deg = lerpf(170.0, 410.0, u)
		pos = Vector2(4, -16).lerp(Vector2(10, 2), u)
	_hip(0.0, -1.0)
	_leg("LegL", -0.5 + t * 0.2, 0.7, 0.15, -1.5)
	_leg("LegR", 0.55 - t * 0.3, 0.35, 0.0, 0.0)
	_torso(lerpf(-0.15, 0.4, t), -2.0)
	_head(0.1)
	_flow(-0.75, 0.5, false)
	_sword(deg, pos)
	modulate = Color(1.08, 1.08, 1.12)


func play_plunge(lock_left: float, lock_total: float) -> void:
	var t: float = 1.0 - clampf(lock_left / maxf(lock_total, 0.01), 0.0, 1.0)
	_hip(0.2, 4.0)
	_leg("LegL", -0.2, 0.35, 0.2, 0.0)
	_leg("LegR", 0.85, 0.15, 0.35, 0.0)
	_torso(0.55, 6.0)
	_head(0.2)
	_sword(lerpf(25.0, 102.0, ease(t, 0.4)), Vector2(6, 4))
	_flow(-0.4, 0.2, false)
	modulate = Color(1.1, 1.08, 1.08)


func play_heavy(lock_left: float, lock_total: float) -> void:
	var t: float = 1.0 - clampf(lock_left / maxf(lock_total, 0.01), 0.0, 1.0)
	var deg: float
	var pos: Vector2
	if t < 0.38:
		var u: float = ease(_span(t, 0.0, 0.38), 0.4)
		deg = lerpf(25.0, 145.0, u)
		pos = _sword_rest().lerp(Vector2(-2, -22), u)
		_hip(0.08, -1.0)
		_leg("LegL", -0.4, 0.45, 0.0, 0.0)
		_leg("LegR", 0.2, 0.25, 0.0, 0.0)
		_torso(lerpf(0.05, 0.42, u), -2.0)
		_head(0.18)
	elif t < 0.52:
		deg = 148.0
		pos = Vector2(-2, -22)
		_hip(0.1, -1.5)
		_leg("LegL", -0.45, 0.5, 0.0, 0.0)
		_leg("LegR", 0.22, 0.22, 0.0, 0.0)
		_torso(0.45, -2.0)
		_head(0.2)
	elif t < 0.78:
		var u: float = ease(_span(t, 0.52, 0.78), 2.8)
		deg = lerpf(148.0, -128.0, u)
		pos = Vector2(-2, -22).lerp(Vector2(16, 8), u)
		_hip(-0.12, 3.0)
		_leg("LegL", lerpf(-0.45, 0.2, u), 0.2, 0.0, 0.0)
		_leg("LegR", lerpf(0.22, 0.6, u), 0.12, 0.0, 0.0)
		_torso(lerpf(0.45, -0.5, u), 3.0)
		_head(-0.14)
	else:
		var u: float = ease(_span(t, 0.78, 1.0), 0.35)
		deg = lerpf(-128.0, -48.0, u)
		pos = Vector2(16, 8).lerp(Vector2(10, 0), u)
		_hip(0.0, 1.0)
		_leg("LegL", 0.1, 0.25, 0.0, 0.0)
		_leg("LegR", 0.45, 0.18, 0.0, 0.0)
		_torso(lerpf(-0.5, -0.15, u), 1.0)
		_head(0.0)
	_flow(-0.65, 0.25, false)
	_sword(deg, pos)
	modulate = Color(1.18, 1.16, 1.12)


func play_kick(lock_left: float, lock_total: float) -> void:
	var t: float = 1.0 - clampf(lock_left / maxf(lock_total, 0.01), 0.0, 1.0)
	if t < 0.22:
		var u: float = ease(_span(t, 0.0, 0.22), 0.45)
		_hip(-0.06, 1.0)
		_leg("LegL", lerpf(0.05, -0.28, u), lerpf(0.2, 0.55, u), 0.05, 0.0)
		_leg("LegR", lerpf(0.1, 0.55, u), lerpf(0.2, 1.45, u), 0.2, -3.0 * u)
		_torso(-0.1, 1.0)
		_head(-0.08)
		_sword(-28.0, _sword_rest() + Vector2(-3, 1))
	elif t < 0.58:
		var u: float = ease(_span(t, 0.22, 0.58), 2.5)
		_hip(0.05, 0.5)
		_leg("LegL", -0.32, 0.6, 0.08, 0.0)
		_leg("LegR", lerpf(0.55, 1.22, u), lerpf(1.45, 0.08, u), lerpf(0.2, 0.45, u), -1.0)
		_torso(-0.22, 1.5)
		_head(-0.04)
		_sword(-48.0, _sword_rest() + Vector2(-6, 0))
	else:
		var u: float = ease(_span(t, 0.58, 1.0), 0.4)
		_hip(0.0, 0.0)
		_leg("LegL", lerpf(-0.32, 0.05, u), lerpf(0.6, 0.2, u), 0.0, 0.0)
		_leg("LegR", lerpf(1.22, 0.15, u), lerpf(0.08, 0.25, u), 0.05, 0.0)
		_torso(lerpf(-0.22, 0.0, u), 0.0)
		_head(0.0)
		_sword(lerpf(-48.0, 10.0, u), _sword_rest())
	_flow(-0.3, 0.15, true)
	modulate = Color(1.06, 1.06, 1.08)


func play_counter(lock_left: float, lock_total: float) -> void:
	var t: float = 1.0 - clampf(lock_left / maxf(lock_total, 0.01), 0.0, 1.0)
	var deg: float
	var pos: Vector2
	if t < 0.22:
		var u: float = _span(t, 0.0, 0.22)
		deg = lerpf(-40.0, -110.0, u)
		pos = Vector2(2, -16)
		_leg("LegL", 0.3, 0.25, 0.0, 0.0)
		_leg("LegR", -0.2, 0.3, 0.0, 0.0)
		_torso(-0.28, 0.0)
	else:
		var u: float = ease(_span(t, 0.22, 1.0), 2.3)
		deg = lerpf(-110.0, 95.0, u)
		pos = Vector2(2, -16).lerp(Vector2(16, 2), u)
		_leg("LegL", lerpf(0.3, -0.15, u), 0.2, 0.0, 0.0)
		_leg("LegR", lerpf(-0.2, 0.5, u), 0.15, 0.0, 0.0)
		_torso(lerpf(-0.28, 0.18, u), 0.0)
	_hip(0.0, 0.0)
	_head(-0.1)
	_flow(-0.5, 0.4, false)
	_sword(deg, pos)
	modulate = Color(1.2, 1.2, 1.18)


func play_charge() -> void:
	_hip(0.06, -1.0)
	_leg("LegL", -0.35, 0.4, 0.0, 0.0)
	_leg("LegR", 0.18, 0.22, 0.0, 0.0)
	_torso(0.32, -1.0)
	_head(0.12)
	_sword(118.0, Vector2(0, -20))
	_flow(0.15, -0.1, true)
	modulate = Color(1.14, 1.14, 1.12)


func play_parry() -> void:
	_hip(0.0, 0.0)
	_leg("LegL", 0.22, 0.2, 0.0, 0.0)
	_leg("LegR", -0.12, 0.25, 0.0, 0.0)
	_sword(-38.0, Vector2(4, -14))
	_torso(-0.08, 0.0)
	_head(0.05)
	_flow(-0.1, 0.05, true)
	modulate = Color(1.16, 1.16, 1.14)


func play_block() -> void:
	_hip(0.0, 1.0)
	_leg("LegL", 0.18, 0.35, 0.0, 0.0)
	_leg("LegR", 0.12, 0.3, 0.0, 0.0)
	_sword(82.0, Vector2(10, -6))
	_torso(-0.14, 0.0)
	_head(0.0)
	_flow(-0.05, 0.0, true)
	modulate = Color(0.88, 0.88, 0.92)


func play_dodge(t: float) -> void:
	var tuck: float = sin(t * PI)
	_hip(0.1, 3.0 * tuck)
	_leg("LegL", -0.95 * tuck, 0.9 * tuck + 0.15, 0.2, -2.0 * tuck)
	_leg("LegR", 0.7 * tuck, 0.35, 0.1, 0.0)
	_torso(0.35 * tuck, 4.0 * tuck)
	_head(0.2 * tuck)
	_sword(lerpf(18.0, -20.0, tuck), _sword_rest() + Vector2(-2.0 * tuck, 2.0 * tuck))
	_flow(-0.6 * tuck, 0.4 * tuck, false)
	modulate = Color(0.9, 0.9, 0.95)


func play_hurt(t: float) -> void:
	var k: float = sin(clampf(t, 0.0, 1.0) * PI)
	_hip(-0.08 * k, 2.0 * k)
	_leg("LegL", 0.3 * k, 0.45 * k + 0.15, 0.1, 0.0)
	_leg("LegR", -0.15 * k, 0.25, 0.0, 0.0)
	_torso(-0.28 * k, 2.0 * k)
	_head(0.2 * k)
	_sword(60.0, _sword_rest() + Vector2(2, 3))
	_flow(0.2, -0.15, true)
	modulate = Color(1.35, 1.2, 1.2)


func _hip(rot: float, y_off: float) -> void:
	var hip := get_node_or_null("Hip") as Node2D
	if hip == null:
		return
	hip.rotation = rot
	hip.position = Vector2(0.0, _hip_base_y() + y_off)


func _leg(leg_name: String, thigh: float, shin: float, foot: float, lift: float) -> void:
	var hip := get_node_or_null("Hip") as Node2D
	if hip == null:
		return
	var thigh_n := hip.get_node_or_null(leg_name) as Node2D
	if thigh_n == null:
		return
	var x: float = -5.0 if leg_name == "LegL" else 5.0
	thigh_n.position = Vector2(x, lift)
	thigh_n.rotation = thigh
	var shin_n := thigh_n.get_node_or_null("Shin") as Node2D
	if shin_n:
		shin_n.rotation = shin
		var foot_n := shin_n.get_node_or_null("Foot") as Node2D
		if foot_n:
			foot_n.rotation = foot


func _torso(rot: float, y_off: float) -> void:
	var t := get_node_or_null("Torso") as Node2D
	if t == null:
		return
	t.rotation = rot
	t.position.y = _hip_base_y() + y_off


func _head(rot: float) -> void:
	var h := get_node_or_null("Torso/Head") as Node2D
	if h:
		h.rotation = rot


func _sword(deg: float, pos: Vector2 = Vector2(9999.0, 9999.0)) -> void:
	var s := sword_node()
	if s == null:
		return
	s.rotation_degrees = deg
	if pos.x > 9000.0:
		s.position = _sword_rest()
	else:
		s.position = pos
