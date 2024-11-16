extends Node2D

var has_started = false
var aim_target = false
var bullet_dir = null
var shooter = null
var target = null
var stop_aim = false
const BULLET_SPEED = 25
const HIT_DIST = 30

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not has_started:
		return
	if aim_target:
		aim_at_target()
	is_colliding()

func is_colliding():
	for node in get_parent().get_children():
		if node == shooter:
			continue
		if node.name in ["Player1", "Player2", "Player3", "Player4"]:
			var distance = position.distance_to(node.position)
			if distance < HIT_DIST:
				node.take_damage(self)
				queue_free()

func set_start_pos(_position):
	if not has_started:
		return
	position = _position

func find_target():
	var closest_dist = 100_000_000
	for node in get_parent().get_children():
		
		if node == shooter:
			continue
			
		if node.name in ["Player1", "Player2", "Player3", "Player4"]:
			print(node.name)
			
			# We dont want to shoot dead people
			if node.is_dead:
				continue
			
			var distance = global_position.distance_to(node.global_position)
			print("Distance to: ", node.name, " is ", distance)
			print(global_position)
			print(node.global_position)
			if distance < closest_dist:
				closest_dist = distance
				target = node
				bullet_dir = shooter.global_position.direction_to(target.global_position)
	
	aim_target = true

func aim_at_target():
	if not has_started:
		return
	if shooter == null:
		return
	if bullet_dir == null:
		return
	if target == null:
		return
	if position.distance_to(target.position) > 100 and not stop_aim:
		var new_dir = position.direction_to(target.position) * 0.2
		bullet_dir = (bullet_dir + new_dir).normalized()
	else:
		stop_aim = true
	position += bullet_dir * BULLET_SPEED
	rotation = bullet_dir.angle()
	
