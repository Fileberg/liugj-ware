extends Minigame

const MAX_ICONS := 10
const ICON_SIZE := 128.0
const START_POSITIONS := [Vector2(200.0, 200.0), Vector2(1720.0, 200.0), Vector2(200.0, 880.0), Vector2(1720.0, 880.0)]

@onready var randy := RandomNumberGenerator.new()
var has_started := false


func _ready():
	var x_size := ($PlayArea as Control).size.x
	var y_size := ($PlayArea as Control).size.y
	$PlayArea/Icon.set_position(Vector2(randy.randf_range(0.0, x_size - ICON_SIZE), randy.randf_range(0.0, y_size - ICON_SIZE)))
	for i in range(MAX_ICONS - 1):
		var new_icon = $PlayArea/Icon.duplicate()
		new_icon.set_position(Vector2(randy.randf_range(0.0, x_size - ICON_SIZE), randy.randf_range(0.0, y_size - ICON_SIZE)))
		$PlayArea.add_child(new_icon)


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


func start() -> void:
	has_started = true
	for child in $Players.get_children():
		child.has_started = true


func _process(delta):
	pass


func _on_timer_timeout():
	finished.emit()
