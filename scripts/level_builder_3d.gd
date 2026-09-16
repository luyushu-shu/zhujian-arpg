extends Node3D

const WORLD_W := 80.0


func _ready() -> void:
	_env()
	_ground()
	_mountains()
	_bamboo()
	_routes()
	_pavilion()


func _mat(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = 0.92
	return m


func _box(parent: Node, pos: Vector3, size: Vector3, color: Color, collide := false) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.material_override = _mat(color)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	if collide:
		var body := StaticBody3D.new()
		body.position = pos
		body.collision_layer = 1
		body.collision_mask = 0
		var cs := CollisionShape3D.new()
		var sh := BoxShape3D.new()
		sh.size = size
		cs.shape = sh
		body.add_child(cs)
		mi.position = Vector3.ZERO
		body.add_child(mi)
		parent.add_child(body)
	else:
		mi.position = pos
		parent.add_child(mi)
	return mi


func _env() -> void:
	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.07, 0.08, 0.11)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.28, 0.3, 0.36)
	env.ambient_light_energy = 0.42
	env.fog_enabled = true
	env.fog_light_color = Color(0.1, 0.12, 0.16)
	env.fog_density = 0.018
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.glow_enabled = true
	env.glow_intensity = 0.18
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.light_color = Color(0.82, 0.86, 0.95)
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	sun.rotation_degrees = Vector3(-42, 36, 0)
	add_child(sun)
	var moon := OmniLight3D.new()
	moon.light_color = Color(0.95, 0.9, 0.7)
	moon.light_energy = 4.0
	moon.omni_range = 18.0
	moon.position = Vector3(28, 12, 6)
	add_child(moon)


func _ground() -> void:
	_box(self, Vector3(WORLD_W * 0.5, -0.4, 0), Vector3(WORLD_W + 8.0, 0.8, 8.0), Color(0.16, 0.18, 0.14, 1), true)
	_box(self, Vector3(WORLD_W * 0.5, 0.02, 0), Vector3(WORLD_W, 0.06, 2.4), Color(0.28, 0.24, 0.16, 1), false)
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	for i in 16:
		var x: float = rng.randf_range(2.0, WORLD_W - 2.0)
		var s: float = rng.randf_range(0.25, 0.7)
		_box(self, Vector3(x, s * 0.25, rng.randf_range(-1.4, 1.4)), Vector3(s * 1.4, s * 0.5, s), Color(0.22, 0.22, 0.2, 1), false)


func _mountains() -> void:
	_box(self, Vector3(20, 4.5, -18), Vector3(28, 10, 6), Color(0.11, 0.14, 0.17, 1), false)
	_box(self, Vector3(48, 5.5, -22), Vector3(34, 13, 7), Color(0.09, 0.12, 0.15, 1), false)
	_box(self, Vector3(70, 3.8, -16), Vector3(22, 8, 5), Color(0.1, 0.13, 0.16, 1), false)


func _bamboo() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 20260916
	for i in 70:
		var x: float = rng.randf_range(-1.0, WORLD_W + 1.0)
		var z: float = rng.randf_range(-3.6, 2.8)
		if absf(z) < 0.7 and x > 4.0 and x < 12.0:
			continue
		_stem(Vector3(x, 0, z), rng.randf_range(3.2, 7.5), rng.randf_range(-8.0, 8.0), rng.randf_range(0.04, 0.09))


func _stem(foot: Vector3, height: float, lean: float, r: float) -> void:
	var mi := MeshInstance3D.new()
	var c := CylinderMesh.new()
	c.top_radius = r * 0.7
	c.bottom_radius = r
	c.height = height
	mi.mesh = c
	mi.material_override = _mat(Color(0.14, 0.28, 0.16, 1))
	mi.position = foot + Vector3(0, height * 0.5, 0)
	mi.rotation_degrees = Vector3(0, 0, lean)
	add_child(mi)


func _routes() -> void:
	_plank(Vector3(13.4, 1.9, 0), Vector3(7.5, 0.18, 1.6))
	_stone(Vector3(26.9, 3.0, 0), Vector3(6.2, 0.22, 1.8))
	_plank(Vector3(36.9, 3.9, 0), Vector3(5.6, 0.16, 1.5))
	_plank(Vector3(61.9, 4.5, 0), Vector3(8.1, 0.16, 1.5))
	_stone(Vector3(71.2, 1.85, 0), Vector3(5.0, 0.22, 1.6))


func _plank(pos: Vector3, size: Vector3) -> void:
	_box(self, pos, size, Color(0.4, 0.26, 0.14, 1), true)


func _stone(pos: Vector3, size: Vector3) -> void:
	_box(self, pos, size, Color(0.34, 0.34, 0.32, 1), true)


func _pavilion() -> void:
	var cx := 47.5
	var fy := 2.35
	_plank(Vector3(cx, fy, 0), Vector3(8.8, 0.2, 3.2))
	for x in [-1.7, 1.7]:
		_box(self, Vector3(cx + x, fy + 1.15, -1.1), Vector3(0.22, 2.3, 0.22), Color(0.36, 0.18, 0.1, 1), false)
		_box(self, Vector3(cx + x, fy + 1.15, 1.1), Vector3(0.22, 2.3, 0.22), Color(0.36, 0.18, 0.1, 1), false)
	_box(self, Vector3(cx, fy + 2.35, 0), Vector3(8.4, 0.16, 3.4), Color(0.42, 0.2, 0.12, 1), false)
	var roof := MeshInstance3D.new()
	var prism := PrismMesh.new()
	prism.size = Vector3(10.0, 1.6, 4.2)
	roof.mesh = prism
	roof.material_override = _mat(Color(0.45, 0.12, 0.1, 1))
	roof.position = Vector3(cx, fy + 3.2, 0)
	add_child(roof)
	var lamp := OmniLight3D.new()
	lamp.light_color = Color(1.0, 0.72, 0.35)
	lamp.light_energy = 2.4
	lamp.omni_range = 6.0
	lamp.position = Vector3(cx, fy + 2.1, 0.4)
	add_child(lamp)
