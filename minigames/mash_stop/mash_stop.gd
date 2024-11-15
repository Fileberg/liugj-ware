extends Minigame

const MAX_ICONS := 10
const ICON_SIZE := 128.0
const POINTS_PER_ICON := 1
const START_POSITIONS := [Vector2(200.0, 200.0), Vector2(1720.0, 200.0), Vector2(200.0, 880.0), Vector2(1720.0, 880.0)]

const MASH_POINT : int = 1
const MASH_MINUS_POINT : int = -2

const BASE_MASH_TIME : float = 0.2
const VAR_MASH_TIME : float = 3.0
const BASE_WAIT_TIME : float = 0.2
const VAR_WAIT_TIME : float = 2.0

@onready var randy := RandomNumberGenerator.new()

var do_mash_state : bool = true

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
	#for child in $Players.get_children():
		#child.has_started = false


func start() -> void:
	has_started = true
	$MashTimer.wait_time = BASE_MASH_TIME + randf_range(0.0, VAR_MASH_TIME)
	$MashTimer.start()
	$Timer.start()


func handle_input(event : InputEvent, player_id : int) -> void:

	if (event.is_action_pressed("p" + str(player_id) + "_jump") or event.is_action_pressed("p" + str(player_id) + "_action")) and not event.is_echo():
		give_points.emit(player_id, mash_points())
		
func _on_timer_timeout():
	has_started = false
	#for child in $Players.get_children():
		#child.has_started = false
	finished.emit()

func mash_points():
	if do_mash_state:
		return MASH_POINT
	else:
		return MASH_MINUS_POINT

func _on_mash_timer_timeout() -> void:
	$Signs/Mash.visible = not do_mash_state
	$Signs/Stop.visible = do_mash_state
	do_mash_state = not do_mash_state
	
	for player in $Players.get_children():
		player.do_mash_state = do_mash_state
	
	if do_mash_state:
		$MashTimer.wait_time = BASE_MASH_TIME + randf_range(0.0, VAR_MASH_TIME)
	else:
		$MashTimer.wait_time = BASE_WAIT_TIME + randf_range(0.0, VAR_WAIT_TIME)
		
	$MashTimer.start()
