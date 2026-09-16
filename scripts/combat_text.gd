class_name CombatText
extends Node2D
## 战斗数字：类型用颜色+字号+前缀，不只靠颜色。

const MAX_ALIVE := 6
static var _alive: int = 0

var _label: Label
var _kind: String = "hurt"
var _body: String = ""


static func popup(into: Node, at: Vector2, body: String, kind: String) -> void:
	if into == null or not is_instance_valid(into):
		return
	if _alive >= MAX_ALIVE:
		return
	var n := CombatText.new()
	n._kind = kind
	n._body = body
	n.global_position = at + Vector2(randf_range(-10.0, 10.0), randf_range(-6.0, 2.0))
	n.z_index = 40
	into.add_child(n)


func _ready() -> void:
	_alive += 1
	_label = Label.new()
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.position = Vector2(-40, -18)
	_label.size = Vector2(80, 28)
	_style_label()
	add_child(_label)
	var rise: float = -28.0
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "position:y", position.y + rise, 0.42).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(_label, "modulate:a", 0.0, 0.28).set_delay(0.18)
	tw.chain().tween_callback(queue_free)


func _exit_tree() -> void:
	_alive = maxi(_alive - 1, 0)


func _style_label() -> void:
	var outline := Color(0.02, 0.02, 0.03, 0.9)
	_label.add_theme_color_override("font_outline_color", outline)
	_label.add_theme_constant_override("outline_size", 5)
	_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.45))
	_label.add_theme_constant_override("shadow_offset_x", 1)
	_label.add_theme_constant_override("shadow_offset_y", 2)
	match _kind:
		"block":
			_label.text = "挡 %s" % _body
			_label.add_theme_font_size_override("font_size", 16)
			_label.add_theme_color_override("font_color", Color(0.72, 0.74, 0.78, 1))
		"parry":
			_label.text = _body
			_label.add_theme_font_size_override("font_size", 22)
			_label.add_theme_color_override("font_color", Color(0.92, 0.9, 0.78, 1))
		_:
			_label.text = _body
			_label.add_theme_font_size_override("font_size", 22)
			_label.add_theme_color_override("font_color", Color(0.96, 0.94, 0.92, 1))


static func popup3d(into: Node, at: Vector3, body: String, kind: String) -> void:
	if into == null or not is_instance_valid(into):
		return
	if _alive >= MAX_ALIVE:
		return
	_alive += 1
	var n := Label3D.new()
	n.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	n.no_depth_test = true
	n.pixel_size = 0.012
	n.outline_render_priority = 1
	n.outline_size = 12
	n.modulate = Color(0.96, 0.94, 0.92, 1)
	n.outline_modulate = Color(0.02, 0.02, 0.03, 0.9)
	n.font_size = 64
	match kind:
		"block":
			n.text = "挡 %s" % body
			n.font_size = 48
			n.modulate = Color(0.72, 0.74, 0.78, 1)
		"parry":
			n.text = body
			n.modulate = Color(0.92, 0.9, 0.78, 1)
		_:
			n.text = body
	n.global_position = at + Vector3(randf_range(-0.12, 0.12), randf_range(0.0, 0.08), 0.15)
	into.add_child(n)
	var tw := n.create_tween()
	tw.set_parallel(true)
	tw.tween_property(n, "position:y", n.position.y + 0.55, 0.42).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(n, "modulate:a", 0.0, 0.28).set_delay(0.18)
	tw.chain().tween_callback(func () -> void:
		_alive = maxi(_alive - 1, 0)
		n.queue_free()
	)
