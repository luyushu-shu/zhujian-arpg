extends CharacterBody3D

const BloodFx := preload("res://scripts/blood_spray_3d.gd")

const SPEED := 2.4
const ATTACK_RANGE := 1.45
const CHASE_RANGE := 9.0
const ATTACK_COOLDOWN := 1.15
const TELEGRAPH := 0.35
const ATTACK_STRIKE := 0.16
const GRAVITY := 22.0

@export var max_hp := 40

var hp := 40
var facing := -1
var attack_cd := 0.6
var stagger := 0.0
var stagger_max := 0.35
var attacking := false

@onready var model: Node3D = $Model
@onready var hitbox: Area3D = $Hitbox
@onready var hit_shape: CollisionShape3D = $Hitbox/CollisionShape3D


func _ready() -> void:
	hp = max_hp
	hit_shape.disabled = true
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	floor_snap_length = 0.12


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	attack_cd = maxf(attack_cd - delta, 0.0)
	stagger = maxf(stagger - delta, 0.0)

	if stagger > 0.0:
		velocity.x = move_toward(velocity.x, 0.0, SPEED * 6.0 * delta)
		velocity.z = 0.0
		model.play_hurt(1.0 - stagger / maxf(stagger_max, 0.01))
		move_and_slide()
		global_position.z = 0.0
		return

	var player := _player()
	if attacking:
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		global_position.z = 0.0
		return

	if player == null:
		velocity.x = 0.0
		velocity.z = 0.0
		model.play_idle(delta)
		move_and_slide()
		global_position.z = 0.0
		return

	var dx := player.global_position.x - global_position.x
	var dist := absf(dx)
	facing = 1 if dx > 0.0 else -1
	_apply_facing()

	if dist <= ATTACK_RANGE and attack_cd <= 0.0:
		_start_attack()
	elif dist <= CHASE_RANGE:
		velocity.x = float(facing) * SPEED
		model.play_loco(delta, 0.5, false)
	else:
		velocity.x = 0.0
		model.play_idle(delta)

	velocity.z = 0.0
	move_and_slide()
	global_position.z = 0.0


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
	velocity = Vector3(side * 3.4, 1.6, 0.0)
	BloodFx.spawn(get_parent(), global_position + Vector3(0, 1.05, 0), Vector3(side, 0.2, 0.1))
	CombatText.popup3d(get_parent(), global_position + Vector3(0, 1.6, 0.2), str(amount), "hurt")
	if hp <= 0:
		queue_free()
	return "hurt"


func receive_parry() -> void:
	stagger_max = 0.85
	stagger = stagger_max
	attacking = false
	hit_shape.disabled = true
	velocity.x = -float(facing) * 5.2


func _on_hitbox_body_entered(body_node: Node3D) -> void:
	if not body_node.has_method("receive_hit"):
		return
	var result: String = body_node.receive_hit(12, global_position.x, true)
	if result == "parried":
		receive_parry()


func _player() -> Node3D:
	return get_tree().get_first_node_in_group("player") as Node3D


func _apply_facing() -> void:
	if model.has_method("set_facing"):
		model.set_facing(facing)
	hitbox.position = Vector3(0.8 * float(facing), 0.9, 0.0)
