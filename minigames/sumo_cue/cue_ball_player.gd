extends PlayerController

var has_started := false
var points_this_round : int = 0
@onready var velocity := Vector2.ZERO

@export var arrow_color = Color.WHITE

const MAX_CHARGE = 800
const CHARGE_SPEED = 400
var shot_charge : float = 0.0

func _ready() -> void:
	$BallBody/ArrowRotPoint/Arrow.modulate = arrow_color
	$BallBody/Ball.modulate = arrow_color

func _physics_process(delta):
	
	$BallBody/ArrowRotPoint/Arrow.visible = false
	if has_started:
		if Input.is_action_pressed(input_jump):
			
			shot_charge += CHARGE_SPEED * delta
			shot_charge = min(shot_charge, MAX_CHARGE)
			$BallBody/ArrowRotPoint/Arrow.visible = true
			
			$BallBody/ArrowRotPoint/Arrow.scale.x = 0.3 * max(shot_charge, 0)/MAX_CHARGE
			
		var input_dir = Input.get_vector(input_left, input_right, input_up, input_down).normalized()
			
		if Input.is_action_just_released(input_jump):
			$BallBody.velocity += input_dir * max(shot_charge, 0)
			shot_charge = -100
		
		$BallBody/ArrowRotPoint.rotation = input_dir.angle()
