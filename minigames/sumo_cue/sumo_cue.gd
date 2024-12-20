extends Minigame

const WINNER_SCORE = 30
var players_in_arena := []

@onready var randy := RandomNumberGenerator.new()

func _ready():
	pass

func prepare(players : Array) -> void:
	var unused_ids := [1, 2, 3, 4]

	for player in players:
		unused_ids.erase(player.id)
		var player_controller = get_node("Players/Player" + str(player.id)) as PlayerController
		player_controller.set_input_names(player.id)
		player_controller.process_mode = PROCESS_MODE_INHERIT
		players_in_arena.append(player_controller)

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


func handle_input(event : InputEvent, player_id : int) -> void:
	pass


func _on_timer_timeout():
	has_started = false
	for child in $Players.get_children():
		child.has_started = false
	finished.emit()


func _on_arena_body_exited(body: Node2D) -> void:
	
	if not has_started:
		return
		
	var dead_player = body.get_parent()
	players_in_arena.erase(dead_player)
	dead_player.queue_free()
	
	if len(players_in_arena) == 1:
		$Timer.stop()
		var winner = players_in_arena[0]
		give_points.emit(winner.input_id, WINNER_SCORE)
		finished.emit()
