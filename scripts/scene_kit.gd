class_name SceneKit
extends RefCounted

static func poly(parent: Node, offset: Vector2, points: PackedVector2Array, color: Color, z := 0) -> Polygon2D:
	var p := Polygon2D.new()
	p.position = offset
	p.polygon = points
	p.color = color
	p.z_index = z
	parent.add_child(p)
	return p


static func rect(parent: Node, center: Vector2, size: Vector2, color: Color, z := 0) -> Polygon2D:
	var hx := size.x * 0.5
	var hy := size.y * 0.5
	return poly(parent, center, PackedVector2Array([
		Vector2(-hx, -hy), Vector2(hx, -hy), Vector2(hx, hy), Vector2(-hx, hy)
	]), color, z)


static func solid_box(parent: Node, center: Vector2, size: Vector2, color: Color, z := 0) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.position = center
	body.collision_layer = 1
	body.collision_mask = 0
	var shape := RectangleShape2D.new()
	shape.size = size
	var cs := CollisionShape2D.new()
	cs.shape = shape
	body.add_child(cs)
	rect(body, Vector2.ZERO, size, color, z)
	parent.add_child(body)
	return body


static func bamboo(parent: Node, foot: Vector2, height: float, lean := 0.0, shade := 0.0, z := -2) -> void:
	var green := Color(0.18 + shade, 0.38 + shade * 0.5, 0.22 + shade, 1)
	var joint := Color(0.12, 0.24, 0.14, 1)
	var w := 7.0 + shade * 4.0
	var top := foot + Vector2(lean, -height)
	poly(parent, Vector2.ZERO, PackedVector2Array([
		foot + Vector2(-w * 0.5, 0),
		foot + Vector2(w * 0.5, 0),
		top + Vector2(w * 0.35, 0),
		top + Vector2(-w * 0.35, 0)
	]), green, z)
	var segs := 5
	for i in segs:
		var t := (float(i) + 1.0) / float(segs + 1)
		var p: Vector2 = foot.lerp(top, t)
		rect(parent, p, Vector2(w + 3.0, 4.0), joint, z)
	var leaf := Color(0.22 + shade, 0.48, 0.26, 0.9)
	for k in 3:
		var side := -1.0 if k == 1 else 1.0
		var lp: Vector2 = foot.lerp(top, 0.72 + k * 0.08)
		poly(parent, Vector2.ZERO, PackedVector2Array([
			lp,
			lp + Vector2(side * (28.0 + k * 6.0), -10.0 - k * 4.0),
			lp + Vector2(side * 8.0, 4.0)
		]), leaf, z)


static func rock(parent: Node, foot: Vector2, scale := 1.0, z := -1) -> void:
	var c := Color(0.28, 0.29, 0.27, 1)
	poly(parent, foot, PackedVector2Array([
		Vector2(-28, 0) * scale,
		Vector2(-18, -22) * scale,
		Vector2(4, -34) * scale,
		Vector2(26, -16) * scale,
		Vector2(22, 0) * scale
	]), c, z)
	poly(parent, foot, PackedVector2Array([
		Vector2(-10, -8) * scale,
		Vector2(2, -20) * scale,
		Vector2(12, -6) * scale
	]), Color(0.36, 0.37, 0.34, 1), z)


static func lantern(parent: Node, hang: Vector2, z := 2) -> void:
	rect(parent, hang + Vector2(0, 8), Vector2(3, 16), Color(0.25, 0.16, 0.1, 1), z)
	rect(parent, hang + Vector2(0, 26), Vector2(16, 20), Color(0.72, 0.22, 0.14, 1), z)
	rect(parent, hang + Vector2(0, 26), Vector2(10, 12), Color(0.92, 0.55, 0.18, 0.85), z)


static func plaque(parent: Node, foot: Vector2, z := 1) -> void:
	rect(parent, foot + Vector2(0, -36), Vector2(10, 72), Color(0.32, 0.2, 0.12, 1), z)
	rect(parent, foot + Vector2(0, -70), Vector2(52, 40), Color(0.45, 0.18, 0.12, 1), z)
	rect(parent, foot + Vector2(0, -70), Vector2(40, 28), Color(0.55, 0.16, 0.12, 1), z)
