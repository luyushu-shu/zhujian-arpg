extends MarginContainer
## 水墨 HUD：安全区内、可扫视、不挡中央战场。

const HELP_FADE_IN := 0.18
const HELP_HOLD := 5.5
const HELP_FADE_OUT := 0.35
const TOAST_IN := 0.16
const TOAST_HOLD := 0.42
const TOAST_OUT := 0.28

var _player: Node
var _hp_fill: ColorRect
var _hp_value: Label
var _hp_tag: Label
var _place: Label
var _toast: Label
var _help: Label
var _help_hint: Label
var _cd_dodge: ColorRect
var _cd_slide: ColorRect
var _charge_fill: ColorRect
var _charge_row: Control
var _help_visible := true
var _toast_busy := false
var _toast_queue: Array[String] = []
var _low_hp := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_constant_override("margin_left", 64)
	add_theme_constant_override("margin_top", 40)
	add_theme_constant_override("margin_right", 64)
	add_theme_constant_override("margin_bottom", 40)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()
	call_deferred("_bind_player")
	_schedule_help_hide()


func _bind_player() -> void:
	_player = get_tree().get_first_node_in_group("player")
	if _player == null:
		return
	if _player.has_signal("hp_changed"):
		_player.hp_changed.connect(_on_hp)
	if _player.has_signal("parry_flash"):
		_player.parry_flash.connect(_on_toast)
	if "hp" in _player and "max_hp" in _player:
		_on_hp(int(_player.hp), int(_player.max_hp))


func _process(_delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		return
	_update_cooldowns()
	_update_charge()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_TAB:
			_toggle_help()


func _on_hp(current: int, maximum: int) -> void:
	var mx := maxi(maximum, 1)
	var ratio: float = clampf(float(current) / float(mx), 0.0, 1.0)
	_low_hp = ratio <= 0.3 and current > 0
	if _hp_fill:
		_hp_fill.anchor_right = ratio
		_hp_fill.offset_right = 0.0
		if current <= 0:
			_hp_fill.color = Color(0.18, 0.16, 0.16, 1)
		elif _low_hp:
			_hp_fill.color = Color(0.62, 0.14, 0.14, 1)
		else:
			_hp_fill.color = Color(0.78, 0.16, 0.16, 1)
	if _hp_value:
		_hp_value.text = "%d / %d" % [current, mx]
	if _hp_tag:
		if current <= 0:
			_hp_tag.text = "绝"
		elif _low_hp:
			_hp_tag.text = "残"
		else:
			_hp_tag.text = "气"


func _on_toast(text: String) -> void:
	if text.is_empty():
		return
	if _toast_queue.size() >= 3:
		_toast_queue.pop_front()
	_toast_queue.append(text)
	_pump_toast()


func _pump_toast() -> void:
	if _toast_busy or _toast_queue.is_empty() or _toast == null:
		return
	_toast_busy = true
	_toast.text = _toast_queue.pop_front()
	_toast.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(_toast, "modulate:a", 1.0, TOAST_IN)
	tw.tween_interval(TOAST_HOLD)
	tw.tween_property(_toast, "modulate:a", 0.0, TOAST_OUT)
	tw.tween_callback(func () -> void:
		_toast_busy = false
		_pump_toast()
	)


func _toggle_help() -> void:
	_help_visible = not _help_visible
	if _help:
		_help.visible = _help_visible
		_help.modulate.a = 1.0 if _help_visible else 0.0
	if _help_hint:
		_help_hint.text = "Tab 收起招式" if _help_visible else "Tab 招式"


func _schedule_help_hide() -> void:
	var tw := create_tween()
	tw.tween_interval(HELP_HOLD)
	tw.tween_property(_help, "modulate:a", 0.0, HELP_FADE_OUT)
	tw.tween_callback(func () -> void:
		_help_visible = false
		if _help:
			_help.visible = false
		if _help_hint:
			_help_hint.text = "Tab 招式"
	)


func _update_cooldowns() -> void:
	if _cd_dodge:
		var d: float = 1.0
		if "dodge_cd" in _player:
			d = 1.0 - clampf(float(_player.dodge_cd) / 0.42, 0.0, 1.0)
		_cd_dodge.anchor_right = d
		_cd_dodge.modulate.a = 1.0 if d < 0.99 else 0.35
	if _cd_slide:
		var s: float = 1.0
		if "slide_cd" in _player:
			s = 1.0 - clampf(float(_player.slide_cd) / 0.55, 0.0, 1.0)
		_cd_slide.anchor_right = s
		_cd_slide.modulate.a = 1.0 if s < 0.99 else 0.35


func _update_charge() -> void:
	if _charge_row == null or _charge_fill == null:
		return
	var charging := false
	var t := 0.0
	if "charging" in _player:
		charging = bool(_player.charging)
	if "charge_t" in _player:
		t = float(_player.charge_t)
	_charge_row.visible = charging
	if charging:
		_charge_fill.anchor_right = clampf(t / 0.38, 0.0, 1.0)


func _build() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(root)

	var top := HBoxContainer.new()
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.anchor_right = 1.0
	top.offset_bottom = 88.0
	root.add_child(top)

	top.add_child(_make_hp_panel())
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(spacer)
	top.add_child(_make_place_panel())

	_toast = Label.new()
	_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_toast.anchor_left = 0.2
	_toast.anchor_right = 0.8
	_toast.anchor_top = 0.12
	_toast.anchor_bottom = 0.12
	_toast.offset_top = -18.0
	_toast.offset_bottom = 28.0
	_toast.add_theme_font_size_override("font_size", 28)
	_toast.add_theme_color_override("font_color", Color(0.95, 0.93, 0.86, 1))
	_outline(_toast)
	_toast.modulate.a = 0.0
	root.add_child(_toast)

	var bottom := VBoxContainer.new()
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.anchor_top = 1.0
	bottom.anchor_bottom = 1.0
	bottom.offset_top = -132.0
	bottom.offset_bottom = 0.0
	bottom.add_theme_constant_override("separation", 8)
	root.add_child(bottom)

	bottom.add_child(_make_cd_row())
	_charge_row = _make_charge_row()
	bottom.add_child(_charge_row)

	_help = Label.new()
	_help.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_help.add_theme_font_size_override("font_size", 16)
	_help.add_theme_color_override("font_color", Color(0.86, 0.84, 0.78, 1))
	_outline(_help)
	_help.text = "A D 移动    Shift 跑 / 点按闪    空格 跳    S 蹲 / 跑中滑    左键 斩    E 踢    F 蓄力    右键 弹刀格挡"
	bottom.add_child(_help)

	_help_hint = Label.new()
	_help_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_help_hint.add_theme_font_size_override("font_size", 16)
	_help_hint.add_theme_color_override("font_color", Color(0.62, 0.6, 0.54, 1))
	_outline(_help_hint)
	_help_hint.text = "Tab 收起招式"
	bottom.add_child(_help_hint)


func _make_hp_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _panel_box())
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_theme_constant_override("separation", 6)
	panel.add_child(col)

	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(row)
	_hp_tag = Label.new()
	_hp_tag.text = "气"
	_hp_tag.add_theme_font_size_override("font_size", 20)
	_hp_tag.add_theme_color_override("font_color", Color(0.9, 0.86, 0.72, 1))
	_outline(_hp_tag)
	row.add_child(_hp_tag)
	var title := Label.new()
	title.text = "血"
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(0.7, 0.68, 0.62, 1))
	_outline(title)
	row.add_child(title)
	var grow := Control.new()
	grow.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(grow)
	_hp_value = Label.new()
	_hp_value.text = "100 / 100"
	_hp_value.add_theme_font_size_override("font_size", 24)
	_hp_value.add_theme_color_override("font_color", Color(0.96, 0.95, 0.92, 1))
	_outline(_hp_value)
	row.add_child(_hp_value)

	var track := Control.new()
	track.custom_minimum_size = Vector2(248, 16)
	track.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(track)
	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.07, 0.07, 1)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	track.add_child(bg)
	_hp_fill = ColorRect.new()
	_hp_fill.color = Color(0.78, 0.16, 0.16, 1)
	_hp_fill.anchor_left = 0.0
	_hp_fill.anchor_top = 0.0
	_hp_fill.anchor_bottom = 1.0
	_hp_fill.anchor_right = 1.0
	_hp_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	track.add_child(_hp_fill)
	var ticks := ColorRect.new()
	ticks.color = Color(0, 0, 0, 0)
	ticks.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ticks.mouse_filter = Control.MOUSE_FILTER_IGNORE
	track.add_child(ticks)
	return panel


func _make_place_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _panel_box())
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.alignment = BoxContainer.ALIGNMENT_END
	panel.add_child(col)
	var sub := Label.new()
	sub.text = "青溪竹径"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	sub.add_theme_font_size_override("font_size", 16)
	sub.add_theme_color_override("font_color", Color(0.72, 0.7, 0.62, 1))
	_outline(sub)
	col.add_child(sub)
	_place = Label.new()
	_place.text = "试剑亭"
	_place.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_place.add_theme_font_size_override("font_size", 22)
	_place.add_theme_color_override("font_color", Color(0.92, 0.88, 0.72, 1))
	_outline(_place)
	col.add_child(_place)
	return panel


func _make_cd_row() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 12)
	_cd_dodge = _cd_chip(row, "闪")
	_cd_slide = _cd_chip(row, "滑")
	return row


func _cd_chip(row: HBoxContainer, title: String) -> ColorRect:
	var box := Control.new()
	box.custom_minimum_size = Vector2(72, 28)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(box)
	var bg := ColorRect.new()
	bg.color = Color(0.06, 0.06, 0.07, 0.72)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(bg)
	var fill := ColorRect.new()
	fill.color = Color(0.55, 0.5, 0.38, 0.85)
	fill.anchor_left = 0.0
	fill.anchor_top = 0.0
	fill.anchor_bottom = 1.0
	fill.anchor_right = 1.0
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(fill)
	var lab := Label.new()
	lab.text = title
	lab.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lab.add_theme_font_size_override("font_size", 16)
	lab.add_theme_color_override("font_color", Color(0.95, 0.93, 0.88, 1))
	_outline(lab)
	lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(lab)
	return fill


func _make_charge_row() -> Control:
	var wrap := Control.new()
	wrap.custom_minimum_size = Vector2(220, 14)
	wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.visible = false
	var bg := ColorRect.new()
	bg.color = Color(0.06, 0.06, 0.07, 0.7)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(bg)
	_charge_fill = ColorRect.new()
	_charge_fill.color = Color(0.82, 0.78, 0.55, 1)
	_charge_fill.anchor_left = 0.0
	_charge_fill.anchor_top = 0.0
	_charge_fill.anchor_bottom = 1.0
	_charge_fill.anchor_right = 0.0
	_charge_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(_charge_fill)
	var lab := Label.new()
	lab.text = "蓄"
	lab.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lab.add_theme_font_size_override("font_size", 16)
	lab.add_theme_color_override("font_color", Color(0.15, 0.14, 0.12, 1))
	lab.add_theme_color_override("font_outline_color", Color(0.95, 0.93, 0.86, 0.7))
	lab.add_theme_constant_override("outline_size", 2)
	lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(lab)
	return wrap


func _panel_box() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.05, 0.05, 0.06, 0.78)
	s.border_color = Color(0.52, 0.46, 0.32, 0.8)
	s.set_border_width_all(1)
	s.border_width_top = 2
	s.content_margin_left = 14
	s.content_margin_right = 14
	s.content_margin_top = 10
	s.content_margin_bottom = 10
	return s


func _outline(lab: Label) -> void:
	lab.add_theme_color_override("font_outline_color", Color(0.02, 0.02, 0.03, 0.88))
	lab.add_theme_constant_override("outline_size", 4)
	lab.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.4))
	lab.add_theme_constant_override("shadow_offset_x", 1)
	lab.add_theme_constant_override("shadow_offset_y", 2)
