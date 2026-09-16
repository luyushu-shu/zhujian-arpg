extends Node3D
## 3D 水墨分件：髋—腿—躯干—臂—剑，走跑跳滑与持剑分姿态。

@export var kind: String = "hero"

var walk_phase := 0.0
var idle_t := 0.0

var vis: Node3D
var hips: Node3D
var spine: Node3D
var chest: Node3D
var head: Node3D
var hat: Node3D
var ribbon: Node3D
var cape: Node3D
var leg_l: Node3D
var shin_l: Node3D
var foot_l: Node3D
var leg_r: Node3D
var shin_r: Node3D
var foot_r: Node3D
var arm_l: Node3D
var forearm_l: Node3D
var arm_r: Node3D
var forearm_r: Node3D
var sword: Node3D
var splash: MeshInstance3D


func _ready() -> void:
	_build()


func _mat(v: float, a: float = 1.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(v, v, v * 1.03, a)
	m.roughness = 0.88
	m.metallic = 0.04
	if a < 1.0:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return m


func _mesh(parent: Node3D, mesh: Mesh, mat: Material, pos: Vector3, rot := Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	mi.rotation_degrees = rot
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(mi)
	return mi


func _cap(r: float, h: float) -> CapsuleMesh:
	var c := CapsuleMesh.new()
	c.radius = r
	c.height = h
	return c


func _box(s: Vector3) -> BoxMesh:
	var b := BoxMesh.new()
	b.size = s
	return b


func _cyl(rt: float, rb: float, h: float) -> CylinderMesh:
	var c := CylinderMesh.new()
	c.top_radius = rt
	c.bottom_radius = rb
	c.height = h
	return c


func _bone(bone_name: String, parent: Node3D, pos: Vector3) -> Node3D:
	var n := Node3D.new()
	n.name = bone_name
	n.position = pos
	parent.add_child(n)
	return n


func _build() -> void:
	var ink := _mat(0.06 if kind == "hero" else 0.14)
	var ink2 := _mat(0.12 if kind == "hero" else 0.2)
	var ink3 := _mat(0.2)
	var boot := _mat(0.04)
	var steel := _mat(0.28)
	var edge := StandardMaterial3D.new()
	edge.albedo_color = Color(0.55, 0.55, 0.58, 1)
	edge.metallic = 0.55
	edge.roughness = 0.35

	vis = _bone("Vis", self, Vector3.ZERO)

	hips = _bone("Hips", vis, Vector3(0, 0.94, 0))
	_mesh(hips, _box(Vector3(0.38, 0.22, 0.22)), ink, Vector3(0, -0.02, 0))
	_mesh(hips, _box(Vector3(0.46, 0.28, 0.24)), ink, Vector3(0, -0.16, 0.02))

	leg_l = _bone("LegL", hips, Vector3(-0.09, -0.08, 0))
	_mesh(leg_l, _cap(0.055, 0.38), ink2, Vector3(0, -0.2, 0))
	shin_l = _bone("ShinL", leg_l, Vector3(0, -0.4, 0))
	_mesh(shin_l, _cap(0.045, 0.34), ink3, Vector3(0, -0.18, 0))
	foot_l = _bone("FootL", shin_l, Vector3(0, -0.36, 0))
	_mesh(foot_l, _box(Vector3(0.22, 0.07, 0.1)), boot, Vector3(0.05, -0.02, 0))

	leg_r = _bone("LegR", hips, Vector3(0.09, -0.08, 0))
	_mesh(leg_r, _cap(0.055, 0.38), ink2, Vector3(0, -0.2, 0))
	shin_r = _bone("ShinR", leg_r, Vector3(0, -0.4, 0))
	_mesh(shin_r, _cap(0.045, 0.34), ink3, Vector3(0, -0.18, 0))
	foot_r = _bone("FootR", shin_r, Vector3(0, -0.36, 0))
	_mesh(foot_r, _box(Vector3(0.22, 0.07, 0.1)), boot, Vector3(0.05, -0.02, 0))

	spine = _bone("Spine", hips, Vector3(0, 0.06, 0))
	chest = _bone("Chest", spine, Vector3(0, 0.28, 0))
	_mesh(chest, _box(Vector3(0.34, 0.42, 0.2)), ink2, Vector3(0, 0.02, 0))
	_mesh(chest, _box(Vector3(0.22, 0.18, 0.28)), ink, Vector3(-0.16, -0.02, 0))
	_mesh(chest, _box(Vector3(0.18, 0.16, 0.22)), ink3, Vector3(0.14, 0.0, 0))

	cape = _bone("Cape", chest, Vector3(-0.04, 0.12, -0.06))
	_mesh(cape, _box(Vector3(0.08, 0.85, 0.55)), ink, Vector3(-0.12, -0.28, -0.12), Vector3(8, 18, 12))
	_mesh(cape, _box(Vector3(0.06, 0.7, 0.35)), ink2, Vector3(-0.06, -0.22, -0.18), Vector3(10, 22, 8))

	head = _bone("Head", chest, Vector3(0, 0.28, 0.02))
	_mesh(head, _cap(0.1, 0.22), ink, Vector3(0, 0.08, 0))
	_mesh(head, _box(Vector3(0.18, 0.08, 0.16)), ink2, Vector3(0, 0.02, 0.02))

	hat = _bone("Hat", head, Vector3(0, 0.16, 0))
	_mesh(hat, _cyl(0.06, 0.16, 0.12), ink, Vector3(0, 0.08, 0))
	_mesh(hat, _cyl(0.42, 0.42, 0.035), ink, Vector3(0, 0.02, 0))
	ribbon = _bone("Ribbon", hat, Vector3(0.12, 0.04, -0.08))
	_mesh(ribbon, _box(Vector3(0.28, 0.03, 0.08)), ink3, Vector3(0.14, -0.02, -0.08), Vector3(10, -20, 8))
	_mesh(ribbon, _box(Vector3(0.22, 0.025, 0.05)), ink, Vector3(0.18, -0.06, -0.14), Vector3(18, -28, 4))

	if kind != "hero":
		hat.visible = false
		ribbon.visible = false

	arm_l = _bone("ArmL", chest, Vector3(-0.16, 0.12, 0.04))
	_mesh(arm_l, _cap(0.04, 0.28), ink, Vector3(0, -0.14, 0))
	forearm_l = _bone("ForearmL", arm_l, Vector3(0, -0.28, 0))
	_mesh(forearm_l, _cap(0.035, 0.26), ink2, Vector3(0, -0.12, 0))

	arm_r = _bone("ArmR", chest, Vector3(0.16, 0.12, 0.04))
	_mesh(arm_r, _cap(0.04, 0.28), ink, Vector3(0, -0.14, 0))
	forearm_r = _bone("ForearmR", arm_r, Vector3(0, -0.28, 0))
	_mesh(forearm_r, _cap(0.035, 0.26), ink2, Vector3(0, -0.12, 0))
	sword = _bone("Sword", forearm_r, Vector3(0.02, -0.24, 0))
	_mesh(sword, _box(Vector3(0.04, 0.1, 0.08)), ink3, Vector3(0, 0.02, 0))
	_mesh(sword, _box(Vector3(0.035, 0.78, 0.045)), steel, Vector3(0, -0.42, 0))
	_mesh(sword, _box(Vector3(0.01, 0.7, 0.012)), edge, Vector3(0.02, -0.42, 0))
	_mesh(sword, _box(Vector3(0.12, 0.025, 0.025)), _mat(0.1), Vector3(0, -0.04, 0))

	splash = _mesh(vis, _cyl(0.55, 0.7, 0.04), _mat(0.05, 0.35), Vector3(0, 0.02, 0))
	splash.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func set_facing(dir: int) -> void:
	if vis:
		vis.rotation.y = 0.0 if dir >= 0 else PI


func _span(t: float, a: float, b: float) -> float:
	return clampf((t - a) / maxf(b - a, 0.0001), 0.0, 1.0)


func _atk(lock_left: float, lock_total: float) -> float:
	return 1.0 - clampf(lock_left / maxf(lock_total, 0.01), 0.0, 1.0)


func play_idle(delta: float = 0.0) -> void:
	walk_phase = 0.0
	idle_t += delta
	var b: float = sin(idle_t * 2.3)
	var w: float = sin(idle_t * 1.6)
	hips.position.y = 0.94 + b * 0.012
	hips.position.x = 0.0
	hips.rotation_degrees = Vector3(4, w * 2.0, 0)
	spine.rotation_degrees = Vector3(6, 0, 2)
	chest.rotation_degrees = Vector3(0, 0, 0)
	head.rotation_degrees = Vector3(-4, 8, 0)
	leg_l.rotation_degrees = Vector3(0, 0, 6)
	shin_l.rotation_degrees = Vector3(0, 0, 10)
	foot_l.rotation_degrees = Vector3(0, 0, -4)
	leg_r.rotation_degrees = Vector3(0, 0, -4)
	shin_r.rotation_degrees = Vector3(0, 0, 8)
	foot_r.rotation_degrees = Vector3(0, 0, -2)
	arm_l.rotation_degrees = Vector3(8, 0, 12)
	forearm_l.rotation_degrees = Vector3(0, 0, 18)
	# 垂剑
	arm_r.rotation_degrees = Vector3(12, 10, 8)
	forearm_r.rotation_degrees = Vector3(8, 0, 14)
	sword.rotation_degrees = Vector3(8, 0, 18 + w * 3.0)
	cape.rotation_degrees = Vector3(6, 16 + w * 6.0, 10)
	ribbon.rotation_degrees = Vector3(8, -18 + w * 12.0, 6)
	splash.visible = true


func play_loco(delta: float, speed_ratio: float, running: bool) -> void:
	var cad: float = 10.5 if running else lerpf(7.2, 9.5, speed_ratio)
	walk_phase += delta * cad
	var ph: float = walk_phase
	var sl: float = sin(ph)
	var sr: float = sin(ph + PI)
	var cl: float = cos(ph)
	var swing_l: float = maxf(0.0, sl)
	var swing_r: float = maxf(0.0, sr)
	var plant_l: float = maxf(0.0, -sl)
	var plant_r: float = maxf(0.0, -sr)
	var th: float = 42.0 if running else 26.0
	var kn: float = 62.0 if running else 38.0
	var bob: float = absf(cl) * (0.045 if running else 0.022)
	hips.position.y = 0.94 + bob
	hips.position.x = 0.0
	hips.rotation_degrees = Vector3(5, sl * (6.0 if running else 3.5), sl * (3.0 if running else 1.5))
	spine.rotation_degrees = Vector3(8 if running else 5, sl * -4.0, 10.0 if running else 3.0)
	chest.rotation_degrees = Vector3(0, sl * -6.0, 0)
	head.rotation_degrees = Vector3(-6, 6 - sl * 4.0, 0)
	leg_l.rotation_degrees = Vector3(0, 0, -sl * th)
	shin_l.rotation_degrees = Vector3(0, 0, 8.0 + swing_l * kn + plant_l * 12.0)
	foot_l.rotation_degrees = Vector3(0, 0, swing_l * -18.0 + plant_l * 8.0)
	leg_r.rotation_degrees = Vector3(0, 0, -sr * th)
	shin_r.rotation_degrees = Vector3(0, 0, 8.0 + swing_r * kn + plant_r * 12.0)
	foot_r.rotation_degrees = Vector3(0, 0, swing_r * -18.0 + plant_r * 8.0)
	arm_l.rotation_degrees = Vector3(6, 0, sl * (38.0 if running else 22.0) + 8.0)
	forearm_l.rotation_degrees = Vector3(0, 0, 16.0 + swing_r * 20.0)
	if running:
		# 拖刀
		arm_r.rotation_degrees = Vector3(18, -25, -28 + sl * 10.0)
		forearm_r.rotation_degrees = Vector3(10, 0, 8)
		sword.rotation_degrees = Vector3(12, 0, 70 + sl * 8.0)
		cape.rotation_degrees = Vector3(12, 28, 18)
	else:
		# 斜提剑，与步伐对摆
		arm_r.rotation_degrees = Vector3(10, 8, 18 - sl * 12.0)
		forearm_r.rotation_degrees = Vector3(6, 0, 22)
		sword.rotation_degrees = Vector3(5, 0, -22 + sl * 10.0)
		cape.rotation_degrees = Vector3(8, 18 + sl * 8.0, 12)
	ribbon.rotation_degrees = Vector3(10, -20 + sl * 18.0, 8)
	splash.visible = true


func play_jump() -> void:
	hips.position.y = 0.98
	hips.rotation_degrees = Vector3(2, 0, -6)
	spine.rotation_degrees = Vector3(4, 0, -8)
	head.rotation_degrees = Vector3(8, 4, 0)
	leg_l.rotation_degrees = Vector3(0, 0, 28)
	shin_l.rotation_degrees = Vector3(0, 0, 55)
	foot_l.rotation_degrees = Vector3(0, 0, 10)
	leg_r.rotation_degrees = Vector3(0, 0, -18)
	shin_r.rotation_degrees = Vector3(0, 0, 22)
	foot_r.rotation_degrees = Vector3(0, 0, 6)
	arm_l.rotation_degrees = Vector3(-8, 0, -24)
	forearm_l.rotation_degrees = Vector3(0, 0, 30)
	arm_r.rotation_degrees = Vector3(-20, 8, -36)
	forearm_r.rotation_degrees = Vector3(0, 0, 18)
	sword.rotation_degrees = Vector3(-12, 0, -40)
	cape.rotation_degrees = Vector3(-8, 12, 6)
	splash.visible = false


func play_fall() -> void:
	hips.position.y = 0.92
	hips.rotation_degrees = Vector3(6, 0, 8)
	spine.rotation_degrees = Vector3(10, 0, 12)
	head.rotation_degrees = Vector3(-8, 6, 0)
	leg_l.rotation_degrees = Vector3(0, 0, -12)
	shin_l.rotation_degrees = Vector3(0, 0, 18)
	foot_l.rotation_degrees = Vector3(0, 0, 12)
	leg_r.rotation_degrees = Vector3(0, 0, 32)
	shin_r.rotation_degrees = Vector3(0, 0, 48)
	foot_r.rotation_degrees = Vector3(0, 0, 8)
	arm_l.rotation_degrees = Vector3(12, 0, 28)
	forearm_l.rotation_degrees = Vector3(0, 0, 20)
	arm_r.rotation_degrees = Vector3(16, 6, 22)
	forearm_r.rotation_degrees = Vector3(8, 0, 16)
	sword.rotation_degrees = Vector3(20, 0, 48)
	cape.rotation_degrees = Vector3(18, 24, 16)
	splash.visible = false


func play_land(t: float) -> void:
	var k: float = 1.0 - clampf(t, 0.0, 1.0)
	hips.position.y = 0.94 - 0.08 * k
	hips.rotation_degrees = Vector3(8, 0, 6 * k)
	spine.rotation_degrees = Vector3(8, 0, 10 * k)
	leg_l.rotation_degrees = Vector3(0, 0, 18 * k)
	shin_l.rotation_degrees = Vector3(0, 0, 28 * k + 8)
	leg_r.rotation_degrees = Vector3(0, 0, 12 * k)
	shin_r.rotation_degrees = Vector3(0, 0, 22 * k + 8)
	arm_r.rotation_degrees = Vector3(12, 8, 10)
	forearm_r.rotation_degrees = Vector3(8, 0, 12)
	sword.rotation_degrees = Vector3(8, 0, lerpf(48.0, 18.0, t))
	splash.visible = true


func play_crouch() -> void:
	hips.position.y = 0.62
	hips.rotation_degrees = Vector3(8, 0, 8)
	spine.rotation_degrees = Vector3(10, 0, 12)
	head.rotation_degrees = Vector3(-4, 8, 0)
	leg_l.rotation_degrees = Vector3(0, 0, 48)
	shin_l.rotation_degrees = Vector3(0, 0, 78)
	foot_l.rotation_degrees = Vector3(0, 0, 8)
	leg_r.rotation_degrees = Vector3(0, 0, 22)
	shin_r.rotation_degrees = Vector3(0, 0, 70)
	foot_r.rotation_degrees = Vector3(0, 0, 6)
	arm_r.rotation_degrees = Vector3(20, 12, 16)
	forearm_r.rotation_degrees = Vector3(8, 0, 10)
	sword.rotation_degrees = Vector3(10, 0, 62)
	cape.rotation_degrees = Vector3(10, 14, 8)
	splash.visible = true


func play_slide(t: float) -> void:
	var k: float = sin(clampf(t, 0.0, 1.0) * PI)
	hips.position.y = 0.42
	hips.rotation_degrees = Vector3(12, 0, 58)
	spine.rotation_degrees = Vector3(8, 0, 28)
	head.rotation_degrees = Vector3(-12, 10, 0)
	leg_l.rotation_degrees = Vector3(0, 0, -8)
	shin_l.rotation_degrees = Vector3(0, 0, 12)
	leg_r.rotation_degrees = Vector3(0, 0, 40)
	shin_r.rotation_degrees = Vector3(0, 0, 35)
	arm_l.rotation_degrees = Vector3(0, 0, 30)
	arm_r.rotation_degrees = Vector3(30, -10, 8)
	forearm_r.rotation_degrees = Vector3(0, 0, 6)
	sword.rotation_degrees = Vector3(70, 0, 88 + k * 8.0)
	cape.rotation_degrees = Vector3(24, 32, 20)
	splash.visible = false


func play_attack(combo_step: int, lock_left: float, lock_total: float) -> void:
	var t: float = _atk(lock_left, lock_total)
	if combo_step <= 1:
		_slash_down(t)
	elif combo_step == 2:
		_slash_up(t)
	else:
		_slash_thrust(t)


func _slash_down(t: float) -> void:
	splash.visible = true
	spine.rotation_degrees = Vector3(6, 0, 0)
	leg_l.rotation_degrees = Vector3(0, 0, 8)
	shin_l.rotation_degrees = Vector3(0, 0, 14)
	leg_r.rotation_degrees = Vector3(0, 0, -6)
	shin_r.rotation_degrees = Vector3(0, 0, 10)
	if t < 0.3:
		var u: float = ease(_span(t, 0.0, 0.3), 0.4)
		spine.rotation_degrees.z = lerpf(4.0, 18.0, u)
		arm_r.rotation_degrees = Vector3(lerpf(10.0, -20.0, u), 12, lerpf(10.0, -70.0, u))
		forearm_r.rotation_degrees = Vector3(0, 0, lerpf(12.0, 8.0, u))
		sword.rotation_degrees = Vector3(0, 0, lerpf(10.0, -20.0, u))
		chest.rotation_degrees = Vector3(0, lerpf(0.0, -12.0, u), 0)
	elif t < 0.58:
		var u: float = ease(_span(t, 0.3, 0.58), 2.5)
		spine.rotation_degrees.z = lerpf(18.0, -16.0, u)
		arm_r.rotation_degrees = Vector3(lerpf(-20.0, 35.0, u), 8, lerpf(-70.0, 95.0, u))
		forearm_r.rotation_degrees = Vector3(0, 0, lerpf(8.0, 20.0, u))
		sword.rotation_degrees = Vector3(lerpf(0.0, 25.0, u), 0, lerpf(-20.0, 30.0, u))
		chest.rotation_degrees = Vector3(0, lerpf(-12.0, 18.0, u), 0)
		leg_r.rotation_degrees.z = lerpf(-6.0, -22.0, u)
	else:
		var u: float = ease(_span(t, 0.58, 1.0), 0.35)
		arm_r.rotation_degrees = Vector3(lerpf(35.0, 18.0, u), 8, lerpf(95.0, 40.0, u))
		forearm_r.rotation_degrees = Vector3(0, 0, 16)
		sword.rotation_degrees = Vector3(12, 0, 18)
		chest.rotation_degrees = Vector3(0, lerpf(18.0, 4.0, u), 0)


func _slash_up(t: float) -> void:
	splash.visible = true
	if t < 0.28:
		var u: float = ease(_span(t, 0.0, 0.28), 0.4)
		spine.rotation_degrees = Vector3(8, 0, 10)
		arm_r.rotation_degrees = Vector3(40, -8, lerpf(40.0, 85.0, u))
		forearm_r.rotation_degrees = Vector3(0, 0, 12)
		sword.rotation_degrees = Vector3(20, 0, 40)
		leg_l.rotation_degrees = Vector3(0, 0, -10)
	elif t < 0.6:
		var u: float = ease(_span(t, 0.28, 0.6), 2.4)
		spine.rotation_degrees.z = lerpf(10.0, -12.0, u)
		arm_r.rotation_degrees = Vector3(lerpf(40.0, -30.0, u), 10, lerpf(85.0, -80.0, u))
		sword.rotation_degrees = Vector3(lerpf(20.0, -10.0, u), 0, lerpf(40.0, -15.0, u))
		leg_l.rotation_degrees.z = lerpf(-10.0, 16.0, u)
	else:
		var u: float = ease(_span(t, 0.6, 1.0), 0.4)
		arm_r.rotation_degrees = Vector3(lerpf(-30.0, -8.0, u), 8, lerpf(-80.0, -20.0, u))
		sword.rotation_degrees = Vector3(0, 0, 8)


func _slash_thrust(t: float) -> void:
	splash.visible = true
	leg_l.rotation_degrees = Vector3(0, 0, 18)
	shin_l.rotation_degrees = Vector3(0, 0, 16)
	leg_r.rotation_degrees = Vector3(0, 0, -20)
	if t < 0.34:
		var u: float = ease(_span(t, 0.0, 0.34), 0.5)
		arm_r.rotation_degrees = Vector3(8, lerpf(0.0, -18.0, u), 20)
		forearm_r.rotation_degrees = Vector3(0, 0, lerpf(20.0, 50.0, u))
		sword.rotation_degrees = Vector3(80, 0, 0)
		chest.rotation_degrees = Vector3(0, -8, 0)
	elif t < 0.62:
		var u: float = ease(_span(t, 0.34, 0.62), 2.6)
		arm_r.rotation_degrees = Vector3(8, lerpf(-18.0, 8.0, u), lerpf(20.0, -8.0, u))
		forearm_r.rotation_degrees = Vector3(0, 0, lerpf(50.0, 8.0, u))
		sword.rotation_degrees = Vector3(90, 0, 0)
		chest.rotation_degrees = Vector3(0, lerpf(-8.0, 14.0, u), 0)
		hips.position.x = u * 0.08
	else:
		var u: float = ease(_span(t, 0.62, 1.0), 0.35)
		forearm_r.rotation_degrees = Vector3(0, 0, lerpf(8.0, 16.0, u))
		sword.rotation_degrees = Vector3(80, 0, 8)
		hips.position.x = (1.0 - u) * 0.08
		chest.rotation_degrees = Vector3(0, 4, 0)


func play_air_slash(lock_left: float, lock_total: float) -> void:
	var t: float = _atk(lock_left, lock_total)
	play_jump()
	spine.rotation_degrees.z = lerpf(-8.0, 16.0, t)
	arm_r.rotation_degrees = Vector3(-10, 20, lerpf(-40.0, 220.0, ease(t, 0.35)))
	forearm_r.rotation_degrees = Vector3(0, 0, 10)
	sword.rotation_degrees = Vector3(10, 0, 20)
	cape.rotation_degrees = Vector3(-6, 20, 10)
	splash.visible = false


func play_plunge(lock_left: float, lock_total: float) -> void:
	var t: float = _atk(lock_left, lock_total)
	hips.position.y = 0.9
	spine.rotation_degrees = Vector3(12, 0, 28)
	head.rotation_degrees = Vector3(-16, 8, 0)
	leg_l.rotation_degrees = Vector3(0, 0, 10)
	leg_r.rotation_degrees = Vector3(0, 0, -28)
	arm_r.rotation_degrees = Vector3(40, 0, 55)
	forearm_r.rotation_degrees = Vector3(0, 0, 8)
	sword.rotation_degrees = Vector3(70, 0, lerpf(20.0, 50.0, t))
	splash.visible = false


func play_heavy(lock_left: float, lock_total: float) -> void:
	var t: float = _atk(lock_left, lock_total)
	splash.visible = true
	if t < 0.38:
		var u: float = ease(_span(t, 0.0, 0.38), 0.4)
		spine.rotation_degrees = Vector3(4, 0, lerpf(4.0, 22.0, u))
		arm_r.rotation_degrees = Vector3(lerpf(10.0, -40.0, u), 12, lerpf(10.0, -100.0, u))
		sword.rotation_degrees = Vector3(-10, 0, -30)
		leg_l.rotation_degrees = Vector3(0, 0, 16)
	elif t < 0.52:
		spine.rotation_degrees = Vector3(4, 0, 24)
		arm_r.rotation_degrees = Vector3(-42, 12, -108)
		sword.rotation_degrees = Vector3(-12, 0, -32)
	elif t < 0.78:
		var u: float = ease(_span(t, 0.52, 0.78), 2.7)
		spine.rotation_degrees.z = lerpf(24.0, -22.0, u)
		arm_r.rotation_degrees = Vector3(lerpf(-42.0, 42.0, u), 8, lerpf(-108.0, 110.0, u))
		sword.rotation_degrees = Vector3(lerpf(-12.0, 30.0, u), 0, 20)
		leg_r.rotation_degrees = Vector3(0, 0, -24)
	else:
		var u: float = ease(_span(t, 0.78, 1.0), 0.35)
		arm_r.rotation_degrees = Vector3(lerpf(42.0, 20.0, u), 8, lerpf(110.0, 50.0, u))
		spine.rotation_degrees.z = lerpf(-22.0, -6.0, u)


func play_kick(lock_left: float, lock_total: float) -> void:
	var t: float = _atk(lock_left, lock_total)
	splash.visible = true
	arm_l.rotation_degrees = Vector3(0, 0, 18)
	arm_r.rotation_degrees = Vector3(16, 8, -18)
	forearm_r.rotation_degrees = Vector3(0, 0, 12)
	sword.rotation_degrees = Vector3(0, 0, -8)
	leg_l.rotation_degrees = Vector3(0, 0, 12)
	shin_l.rotation_degrees = Vector3(0, 0, 28)
	if t < 0.22:
		var u: float = ease(_span(t, 0.0, 0.22), 0.45)
		leg_r.rotation_degrees = Vector3(0, 0, lerpf(0.0, 32.0, u))
		shin_r.rotation_degrees = Vector3(0, 0, lerpf(12.0, 85.0, u))
	elif t < 0.58:
		var u: float = ease(_span(t, 0.22, 0.58), 2.5)
		leg_r.rotation_degrees = Vector3(0, 0, lerpf(32.0, -70.0, u))
		shin_r.rotation_degrees = Vector3(0, 0, lerpf(85.0, 8.0, u))
		spine.rotation_degrees = Vector3(6, 0, -10)
	else:
		var u: float = ease(_span(t, 0.58, 1.0), 0.4)
		leg_r.rotation_degrees = Vector3(0, 0, lerpf(-70.0, 0.0, u))
		shin_r.rotation_degrees = Vector3(0, 0, lerpf(8.0, 12.0, u))
		spine.rotation_degrees = Vector3(6, 0, 0)


func play_counter(lock_left: float, lock_total: float) -> void:
	var t: float = _atk(lock_left, lock_total)
	if t < 0.22:
		arm_r.rotation_degrees = Vector3(-30, 16, -90)
		sword.rotation_degrees = Vector3(0, 0, -20)
		spine.rotation_degrees = Vector3(6, 0, -12)
	else:
		var u: float = ease(_span(t, 0.22, 1.0), 2.3)
		arm_r.rotation_degrees = Vector3(lerpf(-30.0, 28.0, u), 8, lerpf(-90.0, 85.0, u))
		sword.rotation_degrees = Vector3(10, 0, 16)
		spine.rotation_degrees.z = lerpf(-12.0, 10.0, u)
	splash.visible = true


func play_charge() -> void:
	hips.position.y = 0.94
	spine.rotation_degrees = Vector3(6, 0, 16)
	head.rotation_degrees = Vector3(-10, 8, 0)
	leg_l.rotation_degrees = Vector3(0, 0, 16)
	shin_l.rotation_degrees = Vector3(0, 0, 18)
	leg_r.rotation_degrees = Vector3(0, 0, -8)
	arm_r.rotation_degrees = Vector3(-36, 14, -96)
	forearm_r.rotation_degrees = Vector3(0, 0, 10)
	sword.rotation_degrees = Vector3(-16, 0, -28)
	cape.rotation_degrees = Vector3(4, 12, 8)
	splash.visible = true


func play_parry() -> void:
	spine.rotation_degrees = Vector3(6, 0, -6)
	arm_r.rotation_degrees = Vector3(-8, 20, -28)
	forearm_r.rotation_degrees = Vector3(0, 0, 24)
	sword.rotation_degrees = Vector3(0, 0, -18)
	leg_l.rotation_degrees = Vector3(0, 0, -10)
	leg_r.rotation_degrees = Vector3(0, 0, 8)
	splash.visible = true


func play_block() -> void:
	spine.rotation_degrees = Vector3(8, 0, -8)
	arm_r.rotation_degrees = Vector3(8, 18, 42)
	forearm_r.rotation_degrees = Vector3(0, 0, 36)
	sword.rotation_degrees = Vector3(10, 0, 55)
	leg_l.rotation_degrees = Vector3(0, 0, 10)
	shin_l.rotation_degrees = Vector3(0, 0, 16)
	splash.visible = true


func play_dodge(t: float) -> void:
	var k: float = sin(t * PI)
	hips.position.y = 0.94 - 0.12 * k
	spine.rotation_degrees = Vector3(8, 0, 18 * k)
	leg_l.rotation_degrees = Vector3(0, 0, 36 * k)
	shin_l.rotation_degrees = Vector3(0, 0, 40 * k)
	leg_r.rotation_degrees = Vector3(0, 0, -20 * k)
	arm_r.rotation_degrees = Vector3(10, 0, -12)
	sword.rotation_degrees = Vector3(0, 0, -8)
	cape.rotation_degrees = Vector3(10, 22, 14)
	splash.visible = false


func play_hurt(t: float) -> void:
	var k: float = sin(clampf(t, 0.0, 1.0) * PI)
	hips.position.y = 0.94
	spine.rotation_degrees = Vector3(10, 16 * k, -18 * k)
	head.rotation_degrees = Vector3(12 * k, -10, 0)
	arm_r.rotation_degrees = Vector3(20, 0, 30)
	sword.rotation_degrees = Vector3(20, 0, 40)
	leg_l.rotation_degrees = Vector3(0, 0, 16 * k)
	splash.visible = true
