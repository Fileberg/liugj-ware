extends Minigame

const START_POSITIONS := [Vector2(200.0, 200.0), Vector2(1720.0, 200.0), Vector2(200.0, 880.0), Vector2(1720.0, 880.0)]

@onready var randy := RandomNumberGenerator.new()

var icons : Array[Node2D]


func _ready():
	var x_size := ($PlayArea as Control).size.x
	var y_size := ($PlayArea as Control).size.y


func prepare(players : Array) -> void:
	var unused_ids := [1, 2, 3, 4]

	for player in players:
		unused_ids.erase(player.id)
		var player_controller = get_node("Players/Player" + str(player.id)) as PlayerController
		player_controller.set_input_names(player.id)
		player_controller.process_mode = PROCESS_MODE_INHERIT
		player_controller.id = player.id

	for id in unused_ids:
		get_node("Players/Player" + str(id)).queue_free()

	has_started = false
	print($Players.get_children())
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
