extends PlayerController


const BASE_SPEED = 600.0
const DASH_SPEED_BUFF = 1200.0
const SPEED_DECREASE = 1500.0
const AIM_CD = 0.2
const DASH_CD = 1
const MAX_HP = 10

var is_dead = false
var can_shoot = true
var can_dash = true
var is_dashing = false
var current_aim_cd = 0
var current_dash_buff = 0
var current_dash_cd = 0
var movement_speed = BASE_SPEED
var hp = MAX_HP
var id = 0

var has_started := false
var points_this_round : int = 0
@onready var velocity := Vector2.ZERO


func _physics_process(delta):
	var input_dir = Input.get_vector(input_left, input_right, input_up, input_down)

	if is_dashing:
		movement_speed -= delta * SPEED_DECREASE
		
		if movement_speed <= BASE_SPEED:
			movement_speed = BASE_SPEED
			is_dashing = false
	
	# Handle cooldown for shoot and dash, ctrl-c ctrl-v :D
	if not can_shoot:
		current_aim_cd -= delta
		if current_aim_cd <= 0:
			can_shoot = true
	
	if not can_dash:
		current_dash_cd -= delta
		if current_dash_cd <= 0:
			can_dash = true
	
	# k
	if Input.is_action_just_pressed(input_action):
		if not has_started:
			return
		if not can_dash:
			return
			
		is_dashing = true
		movement_speed = BASE_SPEED + DASH_SPEED_BUFF
		current_dash_cd = DASH_CD
		can_dash = false
	
	# j
	if Input.is_action_just_pressed(input_jump):
		if not has_started:
			return
		if not can_shoot:
			return
		
		current_aim_cd = AIM_CD
		can_shoot = false
		var bullet = load("res://minigames/shooty/bullet.tscn")
		var bullet_inst = bullet.instantiate()
		bullet_inst.set_name("bullet")
		bullet_inst.shooter = self
		get_parent().add_child(bullet_inst)
		
		
		if has_started:
			bullet_inst.has_started = true
			bullet_inst.set_start_pos(position)
		
		bullet_inst.find_target()

	if has_started:
		velocity.x = input_dir.x * movement_speed
		velocity.y = input_dir.y * movement_speed

		position.x = clamp(position.x + velocity.x * delta, 0.0, 1920.0)
		position.y = clamp(position.y + velocity.y * delta, 0.0, 1080.0)

	if not input_dir.is_zero_approx():
		$Sprite2D.set_rotation(atan2(input_dir.y, input_dir.x) + PI/2)
	
func take_damage(killer):
	hp -= 1
	if hp == 0:
		is_dead = true
		visible = false
		get_parent().get_parent().give_points.emit(killer.shooter.id, 10)
		var players = []
		var player_count = 0
		# Check if game ended
		for node in get_parent().get_children():
			
			# Found a player
			if node.name in ["Player1", "Player2", "Player3", "Player4"]:
				if node.is_dead:
					continue
				# Dont count ourself since we just died
				if node.name != name:
					player_count += 1
					players.append(node)
				
		# We have a winner
		if player_count == 1:
			for node in players:
				node.has_started = false
			get_parent().get_parent().finished.emit()
			get_parent().get_parent().get_node("Timer").stop()
			get_parent().get_parent().has_started = false
			var winner = players[0]
			get_parent().get_parent().give_points.emit(winner.id, 30)
