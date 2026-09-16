extends CharacterBody2D

const SPEED := 90.0
const ATTACK_RANGE := 46.0
const CHASE_RANGE := 280.0
const ATTACK_COOLDOWN := 1.15
const TELEGRAPH := 0.35
const ATTACK_STRIKE := 0.16

@export var max_hp := 40

var hp := 40
var facing := -1
var attack_cd := 0.6
var stagger := 0.0
var stagger_max := 0.35
var attacking := false
var attack_phase := 0.0

@onready var model: Node2D = $Model
@onready var hitbox: Area2D = $Hitbox
@onready var hit_shape: CollisionShape2D = $Hitbox/CollisionShape2D


func _ready() -> void:
	hp = max_hp
	hit_shape.disabled = true
	hitbox.body_entered.connect(_on_hitbox_body_entered)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += float(ProjectSettings.get_setting("physics/2d/default_gravity")) * delta

	attack_cd = maxf(attack_cd - delta, 0.0)
	stagger = maxf(stagger - delta, 0.0)

	if stagger > 0.0:
		velocity.x = move_toward(velocity.x, 0.0, SPEED * 6.0 * delta)
		model.play_hurt(1.0 - stagger / maxf(stagger_max, 0.01))
		move_and_slide()
		return

	var player := _player()
	if attacking:
		velocity.x = 0.0
		move_and_slide()
		return

	if player == null:
		velocity.x = 0.0
		model.play_idle(delta)
		move_and_slide()
		return

	var dx := player.global_position.x - global_position.x
	var dist := absf(dx)
	facing = 1 if dx > 0.0 else -1
	_apply_facing()

	if dist <= ATTACK_RANGE and attack_cd <= 0.0:
		_start_attack()
	elif dist <= CHASE_RANGE:
		velocity.x = facing * SPEED
		model.play_loco(delta, 0.5, false)
	else:
		velocity.x = 0.0
		model.play_idle(delta)

	move_and_slide()


func _start_attack() -> void:
	attacking = true
	attack_cd = ATTACK_COOLDOWN
	velocity.x = 0.0
	model.play_attack(1, TELEGRAPH, TELEGRAPH)
	await get_tree().create_timer(TELEGRAPH).timeout
	if stagger > 0.0 or not is_instance_valid(self):
		attacking = false
		return
	hit_shape.disabled = false
	model.play_attack(1, 0.02, ATTACK_STRIKE)
	await get_tree().create_timer(ATTACK_STRIKE).timeout
	if is_instance_valid(hit_shape):
		hit_shape.disabled = true
	attacking = false
	if is_instance_valid(model):
		model.play_idle(0.0)


func receive_hit(amount: int, from_x: float, _parriable := true) -> String:
	hp = maxi(hp - amount, 0)
	stagger_max = 0.4
	stagger = stagger_max
	attacking = false
	hit_shape.disabled = true
	var side := signf(global_position.x - from_x)
	velocity = Vector2(side * 140.0, -60.0)
	BloodSpray.spawn(get_parent(), global_position + Vector2(0, -26), Vector2(side, 0.0))
	CombatText.popup(get_parent(), global_position + Vector2(0, -48), str(amount), "hurt")
	if hp <= 0:
		queue_free()
	return "hurt"


func receive_parry() -> void:
	stagger_max = 0.85
	stagger = stagger_max
	attacking = false
	hit_shape.disabled = true
	velocity.x = -facing * 220.0


func _on_hitbox_body_entered(body_node: Node2D) -> void:
	if not body_node.has_method("receive_hit"):
		return
	var result: String = body_node.receive_hit(12, global_position.x, true)
	if result == "parried":
		receive_parry()


func _player() -> Node2D:
	return get_tree().get_first_node_in_group("player") as Node2D


func _apply_facing() -> void:
	var sx := 1.0 if facing >= 0 else -1.0
	model.scale = Vector2(sx, 1.0)
	hitbox.position.x = 32.0 * sx
	hitbox.scale.x = 1.0
