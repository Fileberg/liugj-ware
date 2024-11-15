extends Minigame

const MAX_ICONS := 10
const ICON_SIZE := 128.0
const POINTS_PER_ICON := 1
const START_POSITIONS := [Vector2(200.0, 200.0), Vector2(1720.0, 200.0), Vector2(200.0, 880.0), Vector2(1720.0, 880.0)]

@onready var randy := RandomNumberGenerator.new()

var icons : Array[Node2D]


func _ready():
	var x_size := ($PlayArea as Control).size.x
	var y_size := ($PlayArea as Control).size.y
	$PlayArea/Icon.set_position(Vector2(randy.randf_range(0.0, x_size - ICON_SIZE), randy.randf_range(0.0, y_size - ICON_SIZE)))
	icons = [$PlayArea/Icon]
	for i in range(MAX_ICONS - 1):
		var new_icon = $PlayArea/Icon.duplicate()
		new_icon.set_position(Vector2(randy.randf_range(0.0, x_size - ICON_SIZE), randy.randf_range(0.0, y_size - ICON_SIZE)))
		$PlayArea.add_child(new_icon)
		icons.append(new_icon)


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


func handle_input(event : InputEvent, player_id : int) -> void:
	if (event.is_action_pressed("p" + str(player_id) + "_jump") or event.is_action_pressed("p" + str(player_id) + "_action")) and not event.is_echo():
		for icon in icons:
			if icon.global_position.distance_squared_to(get_node("Players/Player" + str(player_id)).global_position) < ICON_SIZE * ICON_SIZE:
				icon.queue_free()
				icons.erase(icon)
				give_points.emit(player_id, POINTS_PER_ICON)
				break
		if icons.is_empty():
			has_started = false
			for child in $Players.get_children():
				child.has_started = false
			$Timer.stop()
			finished.emit()


func _on_timer_timeout():
	has_started = false
	for child in $Players.get_children():
		child.has_started = false
	finished.emit()
