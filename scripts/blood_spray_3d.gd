class_name BloodSpray3D
extends GPUParticles3D

var away: Vector3 = Vector3(1, 0.3, 0)


func _ready() -> void:
	one_shot = true
	explosiveness = 0.9
	amount = 28
	lifetime = 0.45
	var pm := ParticleProcessMaterial.new()
	var d := away.normalized()
	if d == Vector3.ZERO:
		d = Vector3(0, 1, 0)
	pm.direction = Vector3(d.x, 0.35, d.z)
	pm.spread = 42.0
	pm.initial_velocity_min = 1.6
	pm.initial_velocity_max = 4.2
	pm.gravity = Vector3(0, -9.5, 0)
	pm.scale_min = 0.04
	pm.scale_max = 0.09
	pm.color = Color(0.62, 0.06, 0.08, 1)
	process_material = pm
	var dm := SphereMesh.new()
	dm.radius = 0.04
	dm.height = 0.08
	draw_pass_1 = dm
	emitting = true
	await get_tree().create_timer(0.7).timeout
	queue_free()


static func spawn(into: Node, at: Vector3, dir: Vector3) -> void:
	var scr: GDScript = load("res://scripts/blood_spray_3d.gd") as GDScript
	var n: GPUParticles3D = scr.new()
	n.set("away", dir)
	n.position = at
	into.add_child(n)
