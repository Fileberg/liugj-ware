extends Minigame


const POINTS_PER_LAP := 20

var players : Array[Player]



func _ready():
	pass


func prepare(players_ : Array) -> void:
	players = players_
	var unused_ids := [1, 2, 3, 4]

	for player in players:
		var player_controller = get_node("Path2D/PathFollow" + str(player.id) + "/Player" + str(player.id)) as PlayerController
		unused_ids.erase(player.id)
		player_controller.set_input_names(player.id)
		player_controller.process_mode = PROCESS_MODE_INHERIT
		player_controller.id = player.id

	for id in unused_ids:
		get_node("Path2D/PathFollow" + str(id) + "/Player" + str(id)).queue_free()

	has_started = false
	for player in players:
		get_node("Path2D/PathFollow" + str(player.id) + "/Player" + str(player.id)).has_started = false


func start() -> void:
	has_started = true
	for player in players:
		get_node("Path2D/PathFollow" + str(player.id) + "/Player" + str(player.id)).has_started = true
	$Timer.start()
	$HintLabel.hide()


func handle_input(_event : InputEvent, _player_id) -> void:
	pass


func _on_timer_timeout():
	has_started = false
	for player in players:
		get_node("Path2D/PathFollow" + str(player.id) + "/Player" + str(player.id)).has_started = false
	finished.emit()


func _on_goal_area_racer_entered(area : Area2D) -> void:
	for child in area.get_parent().get_children():
		if child is TrackRacer:
			var racer = child as TrackRacer
			if racer.has_started:
				give_points.emit(racer.id, POINTS_PER_LAP)
