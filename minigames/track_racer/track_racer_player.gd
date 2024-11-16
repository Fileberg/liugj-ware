class_name TrackRacer
extends PlayerController


var has_started := false
var id : int

const CRASH_DURATION := 1.0
var crash_time := 0.0

const ACCELERATION = 1500.0
const DECELERATION = 3000.0
const AUTO_DECELERATION = 250.0
@onready var speed := 0.0

const CRASH_ROTATION := deg_to_rad(360.0 * 1.75)
@onready var last_global_rotation := global_rotation
@onready var last_global_position := global_position

var crash_velocity : Vector2
var crash_rotation_speed : float
@onready var initial_position := position



func _physics_process(delta) -> void:
	if has_started:
		if crash_time == 0.0:
			if Input.is_action_pressed(input_jump):
				speed = speed +  ACCELERATION * delta
			elif Input.is_action_pressed(input_action):
				speed = move_toward(speed, 0.0, DECELERATION * delta)
			else:
				speed = move_toward(speed, 0.0, AUTO_DECELERATION * delta)

			var follower := get_parent() as PathFollow2D
			follower.progress += speed * delta

			var rotation_diff = abs(last_global_rotation - global_rotation)
			if rotation_diff > PI:
				rotation_diff = abs((last_global_rotation) + (global_rotation))
			if rotation_diff > CRASH_ROTATION * delta:
				crash_time = CRASH_DURATION
				crash_velocity = (global_position - last_global_position).normalized() * speed
				crash_rotation_speed = speed

		else:
			crash_time -= delta
			if crash_time <= 0.0:
				crash_time = 0.0
				position = initial_position
				speed = 0.0
				set_rotation(0.0)
			else:
				global_position += crash_velocity * delta
				rotate(crash_rotation_speed * delta)

		last_global_rotation = global_rotation
		last_global_position = global_position
