extends PlayerController


const ROTATION_FORCE = 2

var has_started := false
var do_mash_state := true
var points_this_round : int = 0
var rot_velocity : float = 0.0


func _physics_process(delta):
	if Input.is_action_just_pressed(input_action) or Input.is_action_just_pressed(input_jump):
		if do_mash_state:
			rot_velocity += ROTATION_FORCE
		else:
			rot_velocity -= ROTATION_FORCE
	
	rot_velocity = move_toward(rot_velocity, 0.0, delta*0.5)
	rotate(rot_velocity * delta)
	
	rot_velocity = maxf(rot_velocity, 0.0)
