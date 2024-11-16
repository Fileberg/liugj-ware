extends Minigame

const SURVIVAL_SCORE : int = 20

@onready var randy := RandomNumberGenerator.new()

var icons : Array[Node2D]


func _ready():
	pass


func prepare(players : Array) -> void:
	var unused_ids := [1, 2, 3, 4]

	for player in players:
		unused_ids.erase(player.id)
		var player_controller = get_node("Players/Player" + str(player.id)) as PlayerController
		player_controller.set_input_names(player.id)
		player_controller.process_mode = PROCESS_MODE_INHERIT

	for id in unused_ids:
		get_node("Players/Player" + str(id)).queue_free()

	has_started = false
	for child in $Players.get_children():
		child.has_started = false


func start() -> void:
	has_started = true
	for child in $Players.get_children():
		child.has_started = true
	$Timer.start()
	$DangerSpawner/Timer.start()


func handle_input(event : InputEvent, player_id : int) -> void:
	pass


func _on_timer_timeout():
	has_started = false
	for child in $Players.get_children():
		child.has_started = false
		give_points.emit(child.input_id, SURVIVAL_SCORE)
	finished.emit()
