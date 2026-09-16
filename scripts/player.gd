extends CharacterBody2D

signal hp_changed(current: int, maximum: int)
signal parry_flash(text: String)

const WALK_SPEED := 180.0
const RUN_SPEED := 320.0
const CROUCH_SPEED := 70.0
const JUMP_VELOCITY := -520.0
const COYOTE := 0.10
const JUMP_BUFFER := 0.12
const ATTACK_LOCK := 0.32
const COMBO_WINDOW := 0.42
const PARRY_WINDOW := 0.28
const PARRY_COOLDOWN := 0.45
const BLOCK_DAMAGE := 0.35
const SHIFT_TAP := 0.16
const DODGE_TIME := 0.30
const DODGE_SPEED := 460.0
const DODGE_CD := 0.42
const HURT_TIME := 0.38
const SLIDE_TIME := 0.38
const SLIDE_SPEED := 430.0
const SLIDE_CD := 0.55
const LAND_TIME := 0.16
const AIR_LOCK := 0.30
const PLUNGE_LOCK := 0.22
const PLUNGE_FALL := 780.0
const HEAVY_LOCK := 0.55
const KICK_LOCK := 0.28
const COUNTER_LOCK := 0.34
const COUNTER_WINDOW := 0.50
const CHARGE_NEED := 0.38

@export var max_hp := 100

var hp := 100
var facing := 1
var coyote_left := 0.0
var jump_buffer := 0.0
var attack_lock := 0.0
var attack_lock_max := ATTACK_LOCK
var combo_left := 0.0
var combo_step := 0
var parry_left := 0.0
var parry_cd := 0.0
var blocking := false
var hurt_lock := 0.0
var hurt_max := HURT_TIME
var invuln := 0.0
var shift_held := 0.0
var shift_was_down := false
var running := false
var dodge_left := 0.0
var dodge_cd := 0.0
var last_dir := 1
var attack_style := "light"
var slide_left := 0.0
var slide_cd := 0.0
var land_left := 0.0
var was_air := false
var crouching := false
var charging := false
var charge_t := 0.0
var counter_left := 0.0
var plunge_falling := false

@onready var model: Node2D = $Model
@onready var hitbox: Area2D = $Hitbox
@onready var hit_shape: CollisionShape2D = $Hitbox/CollisionShape2D


func _ready() -> void:
	hp = max_hp
	hp_changed.emit(hp, max_hp)
	hit_shape.disabled = true
	hitbox.body_entered.connect(_on_hitbox_body_entered)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_SPACE:
			jump_buffer = JUMP_BUFFER
		elif event.physical_keycode == KEY_E:
			_try_kick()
		elif event.physical_keycode == KEY_F:
			if hurt_lock <= 0.0 and dodge_left <= 0.0 and attack_lock <= 0.0:
				charging = true
				charge_t = 0.0
	if event is InputEventKey and not event.pressed:
		if event.physical_keycode == KEY_F and charging:
			_release_charge()
	if hurt_lock > 0.0:
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_try_attack()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_try_parry()


func _physics_process(delta: float) -> void:
	_tick_timers(delta)
	_update_shift(delta)
	_update_charge(delta)

	var on_floor_now := is_on_floor()
	if not on_floor_now:
		velocity.y += float(ProjectSettings.get_setting("physics/2d/default_gravity")) * delta
		coyote_left = maxf(coyote_left - delta, 0.0)
		was_air = true
	else:
		coyote_left = COYOTE
		if was_air and attack_style != "plunge":
			land_left = LAND_TIME
		if plunge_falling:
			plunge_falling = false
			attack_lock = PLUNGE_LOCK
			attack_lock_max = PLUNGE_LOCK
			parry_flash.emit("坠击")
		was_air = false

	var hold_s := Input.is_physical_key_pressed(KEY_S)
	crouching = on_floor_now and hold_s and not running and not _busy() and slide_left <= 0.0 and not charging
	if running and hold_s and on_floor_now:
		_try_slide()

	var busy := _busy()
	var dir := 0
	if not busy and not blocking and not crouching and not charging:
		if Input.is_physical_key_pressed(KEY_A):
			dir -= 1
		if Input.is_physical_key_pressed(KEY_D):
			dir += 1
	elif crouching and not busy:
		if Input.is_physical_key_pressed(KEY_A):
			dir -= 1
		if Input.is_physical_key_pressed(KEY_D):
			dir += 1
	if dir != 0:
		facing = dir
		last_dir = dir
	_apply_facing()

	if dodge_left > 0.0:
		velocity.x = facing * DODGE_SPEED
	elif slide_left > 0.0:
		velocity.x = facing * SLIDE_SPEED
	elif plunge_falling:
		velocity.x = facing * 40.0
		velocity.y = PLUNGE_FALL
	elif charging:
		velocity.x = move_toward(velocity.x, 0.0, WALK_SPEED * 10.0 * delta)
	elif not busy and not blocking:
		var spd := CROUCH_SPEED if crouching else (RUN_SPEED if running else WALK_SPEED)
		velocity.x = dir * spd
	elif parry_left > 0.0 or blocking:
		velocity.x = move_toward(velocity.x, 0.0, WALK_SPEED * 8.0 * delta)
	elif attack_lock > 0.0:
		_attack_move(delta)

	if jump_buffer > 0.0 and coyote_left > 0.0 and not busy and not blocking and not charging:
		velocity.y = JUMP_VELOCITY
		jump_buffer = 0.0
		coyote_left = 0.0
		land_left = 0.0
		crouching = false

	blocking = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and not busy and not charging
	_update_pose(delta, dir)
	move_and_slide()


func _busy() -> bool:
	return attack_lock > 0.0 or parry_left > 0.0 or hurt_lock > 0.0 or dodge_left > 0.0 or slide_left > 0.0 or plunge_falling


func _attack_move(delta: float) -> void:
	if attack_style == "heavy" or attack_style == "counter":
		velocity.x = facing * 180.0 * (attack_lock / maxf(attack_lock_max, 0.01))
	elif attack_style == "kick":
		velocity.x = facing * 90.0
	elif attack_style == "air":
		velocity.x = move_toward(velocity.x, facing * 80.0, 400.0 * delta)
		velocity.y *= 0.92
	elif attack_style == "thrust":
		velocity.x = facing * 140.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, WALK_SPEED * 3.0 * delta)


func _update_shift(delta: float) -> void:
	var down := Input.is_physical_key_pressed(KEY_SHIFT)
	if down:
		shift_held += delta
		if shift_held >= SHIFT_TAP and dodge_left <= 0.0 and hurt_lock <= 0.0:
			running = true
	else:
		if shift_was_down and shift_held > 0.0 and shift_held < SHIFT_TAP:
			_try_dodge()
		shift_held = 0.0
		running = false
	shift_was_down = down


func _update_charge(delta: float) -> void:
	if not charging:
		return
	if hurt_lock > 0.0 or dodge_left > 0.0 or slide_left > 0.0:
		charging = false
		charge_t = 0.0
		return
	charge_t += delta
	if charge_t >= CHARGE_NEED:
		_fire_heavy()


func _release_charge() -> void:
	if charge_t >= 0.16:
		_fire_heavy()
	else:
		charging = false
		charge_t = 0.0


func _try_dodge() -> void:
	if dodge_cd > 0.0 or dodge_left > 0.0:
		return
	if _busy() or charging:
		return
	if not is_on_floor():
		return
	dodge_left = DODGE_TIME
	dodge_cd = DODGE_CD
	invuln = DODGE_TIME
	blocking = false
	hit_shape.disabled = true
	parry_flash.emit("闪避")


func _try_slide() -> void:
	if slide_cd > 0.0 or slide_left > 0.0 or dodge_left > 0.0:
		return
	if attack_lock > 0.0 or parry_left > 0.0 or hurt_lock > 0.0 or charging:
		return
	if not is_on_floor():
		return
	slide_left = SLIDE_TIME
	slide_cd = SLIDE_CD
	invuln = 0.18
	attack_style = "slide"
	hit_shape.disabled = false
	parry_flash.emit("滑步")


func _tick_timers(delta: float) -> void:
	jump_buffer = maxf(jump_buffer - delta, 0.0)
	if not plunge_falling:
		attack_lock = maxf(attack_lock - delta, 0.0)
	combo_left = maxf(combo_left - delta, 0.0)
	parry_left = maxf(parry_left - delta, 0.0)
	parry_cd = maxf(parry_cd - delta, 0.0)
	hurt_lock = maxf(hurt_lock - delta, 0.0)
	invuln = maxf(invuln - delta, 0.0)
	dodge_left = maxf(dodge_left - delta, 0.0)
	dodge_cd = maxf(dodge_cd - delta, 0.0)
	slide_left = maxf(slide_left - delta, 0.0)
	slide_cd = maxf(slide_cd - delta, 0.0)
	land_left = maxf(land_left - delta, 0.0)
	counter_left = maxf(counter_left - delta, 0.0)
	if combo_left <= 0.0:
		combo_step = 0
	if attack_lock <= 0.0 and slide_left <= 0.0 and not plunge_falling:
		hit_shape.disabled = true


func _apply_facing() -> void:
	var sx := 1.0 if facing >= 0 else -1.0
	model.scale = Vector2(sx, 1.0)
	var hx := 36.0
	var hy := -24.0
	if attack_style == "kick":
		hx = 24.0
		hy = -10.0
	elif attack_style == "plunge":
		hx = 8.0
		hy = -6.0
	elif attack_style == "heavy" or attack_style == "counter":
		hx = 46.0
	elif attack_style == "air":
		hy = -30.0
	elif attack_style == "slide":
		hx = 28.0
		hy = -12.0
	hitbox.position = Vector2(hx * sx, hy)
	hitbox.scale.x = 1.0


func _try_attack() -> void:
	if hurt_lock > 0.0 or parry_left > 0.0 or blocking or charging:
		return
	if dodge_left > 0.12:
		return
	if slide_left > 0.0 or plunge_falling:
		return
	if attack_lock > 0.0:
		return
	if counter_left > 0.0:
		_start_attack("counter", COUNTER_LOCK)
		counter_left = 0.0
		parry_flash.emit("反击")
		return
	if not is_on_floor():
		combo_step = 0
		combo_left = 0.0
		if Input.is_physical_key_pressed(KEY_S):
			attack_style = "plunge"
			plunge_falling = true
			attack_lock = 2.0
			attack_lock_max = 2.0
			hit_shape.disabled = false
			combo_left = 0.0
			parry_flash.emit("下劈")
		else:
			_start_attack("air", AIR_LOCK)
		return
	if crouching:
		_try_kick()
		return
	combo_step = 1 if combo_left <= 0.0 else mini(combo_step + 1, 3)
	combo_left = COMBO_WINDOW
	if combo_step == 3:
		_start_attack("thrust", ATTACK_LOCK + 0.06)
	else:
		attack_style = "light"
		attack_lock_max = ATTACK_LOCK + (0.08 if combo_step == 2 else 0.0)
		attack_lock = attack_lock_max
		hit_shape.disabled = false


func _try_kick() -> void:
	if _busy() or blocking or charging or not is_on_floor():
		return
	_start_attack("kick", KICK_LOCK)
	parry_flash.emit("踢")


func _fire_heavy() -> void:
	charging = false
	charge_t = 0.0
	if hurt_lock > 0.0 or dodge_left > 0.0:
		return
	if not is_on_floor() or plunge_falling:
		return
	_start_attack("heavy", HEAVY_LOCK)
	parry_flash.emit("重斩")


func _start_attack(style: String, lock: float) -> void:
	attack_style = style
	attack_lock_max = lock
	attack_lock = lock
	hit_shape.disabled = false
	combo_left = COMBO_WINDOW if style == "light" or style == "thrust" else 0.0


func _try_parry() -> void:
	if parry_cd > 0.0 or attack_lock > 0.0 or hurt_lock > 0.0 or dodge_left > 0.0 or charging:
		return
	parry_left = PARRY_WINDOW
	parry_cd = PARRY_COOLDOWN
	hit_shape.disabled = true
	parry_flash.emit("弹刀")


func is_parrying() -> bool:
	return parry_left > 0.0


func is_blocking() -> bool:
	return blocking and parry_left <= 0.0


func receive_hit(amount: int, from_x: float, parriable := true) -> String:
	if invuln > 0.0 or dodge_left > 0.0 or slide_left > 0.0:
		return "ignored"
	if parriable and is_parrying():
		parry_flash.emit("弹刀！")
		CombatText.popup(get_parent(), global_position + Vector2(0, -52), "弹", "parry")
		invuln = 0.15
		counter_left = COUNTER_WINDOW
		return "parried"
	charging = false
	charge_t = 0.0
	var dmg := amount
	var blocked := is_blocking()
	if blocked:
		dmg = int(ceil(float(amount) * BLOCK_DAMAGE))
		parry_flash.emit("格挡")
	hp = maxi(hp - dmg, 0)
	hp_changed.emit(hp, max_hp)
	CombatText.popup(
		get_parent(),
		global_position + Vector2(0, -50),
		str(dmg),
		"block" if blocked else "hurt"
	)
	hurt_max = HURT_TIME
	hurt_lock = HURT_TIME
	invuln = 0.22
	var side := signf(global_position.x - from_x)
	if side == 0.0:
		side = -float(facing)
	velocity = Vector2(side * 200.0, -110.0)
	if not blocked:
		_blood(Vector2(side, 0.0))
	if hp <= 0:
		_die()
	return "blocked" if blocked else "hurt"


func _blood(away: Vector2) -> void:
	BloodSpray.spawn(get_parent(), global_position + Vector2(0, -28), away)


func _die() -> void:
	hurt_lock = 999.0
	parry_flash.emit("气绝")
	await get_tree().create_timer(0.8).timeout
	get_tree().reload_current_scene()


func _on_hitbox_body_entered(body_node: Node2D) -> void:
	if body_node == self:
		return
	if not body_node.has_method("receive_hit"):
		return
	var dmg := 14
	if attack_style == "kick" or attack_style == "slide":
		dmg = 10
	elif combo_step == 2:
		dmg = 18
	elif attack_style == "thrust" or combo_step >= 3:
		dmg = 22
	elif attack_style == "air":
		dmg = 16
	elif attack_style == "plunge":
		dmg = 26
	elif attack_style == "heavy":
		dmg = 32
	elif attack_style == "counter":
		dmg = 28
	body_node.receive_hit(dmg, global_position.x, attack_style != "kick" and attack_style != "slide")


func _update_pose(delta: float, dir: int) -> void:
	if hurt_lock > 0.0:
		model.play_hurt(1.0 - hurt_lock / hurt_max)
		return
	if dodge_left > 0.0:
		model.play_dodge(1.0 - dodge_left / DODGE_TIME)
		return
	if slide_left > 0.0:
		model.play_slide(1.0 - slide_left / SLIDE_TIME)
		return
	if charging:
		model.play_charge()
		return
	if plunge_falling or (attack_lock > 0.0 and attack_style == "plunge"):
		model.play_plunge(attack_lock, attack_lock_max)
		return
	if attack_lock > 0.0:
		if attack_style == "air":
			model.play_air_slash(attack_lock, attack_lock_max)
		elif attack_style == "heavy":
			model.play_heavy(attack_lock, attack_lock_max)
		elif attack_style == "kick":
			model.play_kick(attack_lock, attack_lock_max)
		elif attack_style == "counter":
			model.play_counter(attack_lock, attack_lock_max)
		else:
			model.play_attack(combo_step, attack_lock, attack_lock_max)
		return
	if parry_left > 0.0:
		model.play_parry()
		return
	if blocking:
		model.play_block()
		return
	if land_left > 0.0:
		model.play_land(1.0 - land_left / LAND_TIME)
		return
	if not is_on_floor():
		if velocity.y < 0.0:
			model.play_jump()
		else:
			model.play_fall()
		return
	if crouching:
		model.play_crouch()
		return
	if dir != 0:
		model.play_loco(delta, 1.0 if running else 0.45, running)
		return
	model.play_idle(delta)
