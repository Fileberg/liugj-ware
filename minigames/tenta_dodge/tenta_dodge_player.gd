extends PlayerController


const MOVE_SPEED = 400.0

var has_started := false
var points_this_round : int = 0
@onready var velocity := Vector2.ZERO
@export var color : Color = Color.WHITE

func _ready() -> void:
	$Sprite2D.modulate = color

func _physics_process(delta):
	var input_dir = Input.get_vector(input_left, input_right, input_up, input_down).normalized()

	if has_started:
		velocity.x = input_dir.x * MOVE_SPEED
		velocity.y = input_dir.y * MOVE_SPEED

		position.x = clamp(position.x + velocity.x * delta, 0.0, 1920.0)
		position.y = clamp(position.y + velocity.y * delta, 0.0, 1080.0)

	if not input_dir.is_zero_approx():
		$Sprite2D.set_rotation(atan2(input_dir.y, input_dir.x) + PI/2)


func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("death_box"):
		queue_free()
