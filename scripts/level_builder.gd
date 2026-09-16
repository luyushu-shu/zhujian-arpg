extends Node2D

const Kit = preload("res://scripts/scene_kit.gd")
const WORLD_W := 2560.0
const GROUND_TOP := 640.0


func _ready() -> void:
	_sky()
	_mountains()
	_far_bamboo()
	_ground()
	_mid_props()
	_routes()
	_pavilion()
	_front_bamboo()


func _sky() -> void:
	var bg := get_parent().get_node("ParallaxBackground")
	var far := ParallaxLayer.new()
	far.motion_scale = Vector2(0.08, 0.2)
	bg.add_child(far)
	# dusk wash
	Kit.rect(far, Vector2(WORLD_W * 0.5, 360), Vector2(WORLD_W * 1.4, 900), Color(0.10, 0.13, 0.18, 1), -20)
	Kit.rect(far, Vector2(WORLD_W * 0.5, 200), Vector2(WORLD_W * 1.4, 420), Color(0.16, 0.12, 0.14, 1), -19)
	# moon
	Kit.rect(far, Vector2(980, 110), Vector2(54, 54), Color(0.93, 0.9, 0.72, 0.9), -18)
	Kit.rect(far, Vector2(992, 104), Vector2(20, 20), Color(0.10, 0.13, 0.18, 1), -17)
	# haze band
	Kit.poly(far, Vector2.ZERO, PackedVector2Array([
		Vector2(-200, 380), Vector2(2800, 340), Vector2(2800, 720), Vector2(-200, 720)
	]), Color(0.15, 0.22, 0.24, 0.45), -16)


func _mountains() -> void:
	var bg := get_parent().get_node("ParallaxBackground")
	var layer := ParallaxLayer.new()
	layer.motion_scale = Vector2(0.22, 0.35)
	bg.add_child(layer)
	Kit.poly(layer, Vector2.ZERO, PackedVector2Array([
		Vector2(-100, 620), Vector2(180, 300), Vector2(420, 420), Vector2(640, 250),
		Vector2(900, 390), Vector2(1180, 220), Vector2(1500, 360), Vector2(1840, 240),
		Vector2(2200, 380), Vector2(2600, 280), Vector2(2800, 620)
	]), Color(0.12, 0.16, 0.2, 1), -12)
	Kit.poly(layer, Vector2.ZERO, PackedVector2Array([
		Vector2(-80, 620), Vector2(260, 390), Vector2(520, 470), Vector2(780, 340),
		Vector2(1100, 430), Vector2(1420, 330), Vector2(1760, 450), Vector2(2100, 360),
		Vector2(2480, 440), Vector2(2800, 620)
	]), Color(0.09, 0.14, 0.16, 1), -11)


func _far_bamboo() -> void:
	var bg := get_parent().get_node("ParallaxBackground")
	var layer := ParallaxLayer.new()
	layer.motion_scale = Vector2(0.45, 0.6)
	bg.add_child(layer)
	var rng := RandomNumberGenerator.new()
	rng.seed = 20260916
	for i in 42:
		var x := rng.randf_range(-40.0, WORLD_W + 80.0)
		var h := rng.randf_range(180.0, 420.0)
		var lean := rng.randf_range(-18.0, 18.0)
		Kit.bamboo(layer, Vector2(x, GROUND_TOP + 20.0), h, lean, rng.randf_range(-0.06, 0.04), -8)


func _ground() -> void:
	# collision + layered soil
	Kit.solid_box(self, Vector2(WORLD_W * 0.5, GROUND_TOP + 40.0), Vector2(WORLD_W, 80), Color(0.14, 0.16, 0.12, 1), -1)
	Kit.rect(self, Vector2(WORLD_W * 0.5, GROUND_TOP + 6.0), Vector2(WORLD_W, 14), Color(0.22, 0.32, 0.16, 1), 0)
	# path
	Kit.poly(self, Vector2.ZERO, PackedVector2Array([
		Vector2(40, GROUND_TOP - 2), Vector2(620, GROUND_TOP - 8), Vector2(1280, GROUND_TOP - 4),
		Vector2(1900, GROUND_TOP - 10), Vector2(2520, GROUND_TOP - 2),
		Vector2(2520, GROUND_TOP + 18), Vector2(40, GROUND_TOP + 18)
	]), Color(0.30, 0.26, 0.18, 1), 0)
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	for i in 18:
		Kit.rock(self, Vector2(rng.randf_range(80, WORLD_W - 80), GROUND_TOP), rng.randf_range(0.45, 1.1), 1)


func _mid_props() -> void:
	Kit.plaque(self, Vector2(168, GROUND_TOP), 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	for i in 16:
		Kit.bamboo(self, Vector2(rng.randf_range(40, 520), GROUND_TOP), rng.randf_range(160, 340), rng.randf_range(-12, 12), rng.randf_range(0.0, 0.08), -1)
	for i in 14:
		Kit.bamboo(self, Vector2(rng.randf_range(1680, 2500), GROUND_TOP), rng.randf_range(140, 360), rng.randf_range(-14, 14), rng.randf_range(0.0, 0.1), -1)


func _routes() -> void:
	# 木栈：近起点
	_wood_plank(Vector2(430, 518), Vector2(240, 18))
	# 石台
	_stone_ledge(Vector2(860, 448), Vector2(200, 22))
	# 断桥木板
	_wood_plank(Vector2(1180, 390), Vector2(180, 16))
	# 亭基在 _pavilion
	# 高处竹架
	_wood_plank(Vector2(1980, 350), Vector2(260, 16))
	# 落石台
	_stone_ledge(Vector2(2280, 520), Vector2(160, 22))


func _wood_plank(center: Vector2, size: Vector2) -> void:
	var body := Kit.solid_box(self, center, size, Color(0.42, 0.28, 0.14, 1), 3)
	Kit.rect(body, Vector2(0, -size.y * 0.35), Vector2(size.x - 8, 3), Color(0.55, 0.38, 0.2, 1), 4)
	for i in 4:
		var x := -size.x * 0.5 + 20 + i * (size.x - 40) / 3.0
		Kit.rect(body, Vector2(x, size.y * 0.7), Vector2(6, 18), Color(0.28, 0.18, 0.1, 1), 2)


func _stone_ledge(center: Vector2, size: Vector2) -> void:
	var body := Kit.solid_box(self, center, size, Color(0.36, 0.36, 0.34, 1), 3)
	Kit.rect(body, Vector2(-size.x * 0.2, -2), Vector2(size.x * 0.4, size.y * 0.45), Color(0.44, 0.44, 0.4, 1), 4)


func _pavilion() -> void:
	var floor_y := 488.0
	var cx := 1520.0
	_wood_plank(Vector2(cx, floor_y), Vector2(280, 20))
	# pillars sit on floor
	for x in [-110.0, 110.0]:
		Kit.rect(self, Vector2(cx + x, floor_y - 56), Vector2(14, 112), Color(0.38, 0.2, 0.12, 1), 4)
	# beam
	Kit.rect(self, Vector2(cx, floor_y - 114), Vector2(270, 12), Color(0.45, 0.22, 0.12, 1), 5)
	# 飞檐屋顶
	Kit.poly(self, Vector2(cx, floor_y - 118), PackedVector2Array([
		Vector2(-160, 8), Vector2(0, -70), Vector2(160, 8), Vector2(120, 18), Vector2(0, -40), Vector2(-120, 18)
	]), Color(0.62, 0.16, 0.12, 1), 6)
	Kit.poly(self, Vector2(cx, floor_y - 118), PackedVector2Array([
		Vector2(-20, -8), Vector2(0, -78), Vector2(20, -8)
	]), Color(0.35, 0.12, 0.1, 1), 7)
	Kit.lantern(self, Vector2(cx - 48, floor_y - 114), 8)
	Kit.lantern(self, Vector2(cx + 48, floor_y - 114), 8)


func _front_bamboo() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	for i in 10:
		var x := rng.randf_range(0, WORLD_W)
		if x > 180 and x < 320:
			continue
		Kit.bamboo(self, Vector2(x, GROUND_TOP + 8), rng.randf_range(220, 480), rng.randf_range(-22, 22), rng.randf_range(0.04, 0.12), 12)
