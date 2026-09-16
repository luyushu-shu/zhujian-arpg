class_name BloodSpray
extends CPUParticles2D


func _ready() -> void:
	z_index = 30
	one_shot = true
	explosiveness = 0.92
	amount = 26
	lifetime = 0.45
	preprocess = 0.0
	local_coords = false
	gravity = Vector2(0, 480)
	spread = 48
	initial_velocity_min = 90
	initial_velocity_max = 240
	scale_amount_min = 1.4
	scale_amount_max = 3.2
	color = Color(0.72, 0.05, 0.08, 1)
	emitting = true
	await get_tree().create_timer(0.7).timeout
	queue_free()


static func spawn(into: Node, at: Vector2, away: Vector2) -> void:
	var n := BloodSpray.new()
	n.global_position = at
	var d := away.normalized()
	if d == Vector2.ZERO:
		d = Vector2(0, -1)
	n.direction = Vector2(d.x, -0.35)
	into.add_child(n)
