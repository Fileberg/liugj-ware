extends Node2D

const BASE_SPAWN_TIME = 0.2
const VAR_SPAWN_TIME = 0.2

@export var spawnarea : Area2D
@export var spawn_dir : Vector2 = Vector2.DOWN

@onready var danger_scene = preload("res://minigames/tenta_dodge/danger_area.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.wait_time = BASE_SPAWN_TIME + randf_range(0.0, VAR_SPAWN_TIME)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	var size_x = spawnarea.get_node("CollisionShape2D").get_shape().get_rect().size.x
	var size_y = spawnarea.get_node("CollisionShape2D").get_shape().get_rect().size.y
	
	var spawn_point = position + Vector2(randf_range(-size_x/2, size_x/2), randf_range(-size_y/2, size_y/2))
	
	var danger = danger_scene.instantiate()
	
	danger.direction = spawn_dir
	get_parent().add_child(danger)
	danger.position = spawn_point
	
	$Timer.wait_time = BASE_SPAWN_TIME + randf_range(0.0, VAR_SPAWN_TIME)
