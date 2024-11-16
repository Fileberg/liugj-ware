extends Node

const INPUT_NAMES = ["left", "right", "up", "down", "action", "jump"]

const JOY_AXIS_INPUTS = [
	[[JOY_AXIS_LEFT_X, -1.0]],
	[[JOY_AXIS_LEFT_X, 1.0]],
	[[JOY_AXIS_LEFT_Y, -1.0]],
	[[JOY_AXIS_LEFT_Y, 1.0]],
	[],
	[]
]

const JOY_BUTTON_INPUTS = [
	[JOY_BUTTON_DPAD_LEFT],
	[JOY_BUTTON_DPAD_RIGHT],
	[JOY_BUTTON_DPAD_UP],
	[JOY_BUTTON_DPAD_DOWN],
	[JOY_BUTTON_X],
	[JOY_BUTTON_A]
]

const ANIMATION_START_MINIGAME := "start_minigame"
const ANIMATION_OPEN_SCENE := "open_scene"
const ANIMATION_CLOSE_SCENE := "close_scene"

const MAX_PLAYERS := 4
var players : Array[Player]

var on_main_menu := true

var minigames : Array
var current_minigame : Minigame
var minigames_played := 0
const MAX_MINIGAMES_PLAYED := 5
const WAIT_TIME_MINIGAME := 1.0
const WAIT_TIME_GAME_OVER := 5.0

@onready var randy := RandomNumberGenerator.new()
@onready var _animator := $AnimationPlayer as AnimationPlayer
@onready var _timer := $Timer as Timer


func _ready() -> void:
	players = []
	minigames = Array()
	#minigames.append(load("res://minigames/click_icons/click_icons.tscn"))
	minigames.append(load("res://minigames/shooty/shooty.tscn"))
	#minigames.append(load("res://minigames/mash_stop/mash_stop.tscn"))
	#minigames.append(load("res://minigames/sumo_cue/sumo_cue.tscn"))
	#minigames.append(load("res://minigames/tenta_dodge/tenta_dodge.tscn"))
	#add_player(1, 2)
	#add_player(2, 3)
	#add_player(3, 4)


func _unhandled_input(event : InputEvent):
	# Add players in main menu
	if event.is_action_pressed("start") and not event.is_echo() and on_main_menu:
		var add_new_player = true
		for player in players:
			if player.device == event.device:
				remove_player_input(player.id)
				get_node("PlayerLabel" + str(player.id)).set_active(false)
				players.erase(player)
				add_new_player = false
		if add_new_player and players.size() < MAX_PLAYERS:
			var player_number := 0
			while player_number < players.size() and player_number == players[player_number].id - 1:
				player_number += 1
			add_player(player_number + 1, event.device)

	elif event.is_action_pressed("ready_up") and not event.is_echo() and on_main_menu:
		for player in players:
			if player.device == event.device:
				player.ready = not player.ready
				get_node("PlayerLabel" + str(player.id)).set_ready_label(player.ready)
				var all_player_ready = true
				for player2 in players:
					if not player2.ready:
						all_player_ready = false
						break
				if all_player_ready:
					_start_playing()

	# Forward events to the minigame otherwise
	elif not current_minigame == null and current_minigame.has_started:
		var player_id = 0
		for player in players:
			if player.device == event.device:
				player_id = player.id
				break
		current_minigame.handle_input(event, player_id)


func _on_minigame_give_player_points(player_id, points) -> void:
	var highest_points := 0
	var winning_player_ids : Array[int] = []
	for player in players:
		if player.id == player_id:
			player.points += points
			get_node("PlayerLabel" + str(player.id)).set_points(player.points)

		if player.points >= highest_points:
			highest_points = player.points
			winning_player_ids.append(player.id)

	for player in players:
		get_node("PlayerLabel" + str(player.id)).set_winning(player.id in winning_player_ids)


func _on_minigame_finished() -> void:
	#print("minigame finished!")
	minigames_played += 1
	_animator.play(ANIMATION_CLOSE_SCENE)


func _on_timer_timeout():
	_animator.play(ANIMATION_OPEN_SCENE)



func _on_animation_player_animation_finished(anim_name : String) -> void:
	match anim_name:
		#ANIMATION_START_MINIGAME:
			#current_minigame.start()

		ANIMATION_CLOSE_SCENE:
			if $MainMenu.is_visible_in_tree():
				$MainMenu.hide()
			for player in players:
				get_node("PlayerLabel" + str(player.id)).set_points(player.points)
			if minigames_played < MAX_MINIGAMES_PLAYED:
				_load_new_minigame()
				_timer.start(WAIT_TIME_MINIGAME)
			else:
				_go_back_to_main_menu()
				_timer.start(WAIT_TIME_GAME_OVER)

		ANIMATION_OPEN_SCENE:
			if not current_minigame == null: # Means minigame is starting
				_animator.play(ANIMATION_START_MINIGAME)
			else: # Means Main menu is being shown after GAME OVER
				on_main_menu = true
				minigames_played = 0

				for i in range(1, 5):
					var label := get_node("PlayerLabel" + str(i)) as Control
					if label.is_visible_in_tree():
						label.set_ready_label(false)
						for player in players:
							if player.id == i:
								player.ready = 0
								player.points = 0
								break
					else:
						#label.set_active(false)
						label.show()


#############################
#   Helper function stuff   #
#############################

func start_minigame():
	current_minigame.start()


func _start_playing() -> void:
	var unused_ids := [1, 2, 3, 4]
	for player in players:
		unused_ids.erase(player.id)
		get_node("PlayerLabel" + str(player.id)).show()

	for id in unused_ids:
		get_node("PlayerLabel" + str(id)).hide()

	on_main_menu = false
	_animator.play(ANIMATION_CLOSE_SCENE)


func _go_back_to_main_menu() -> void:
	$MainMenu.show()
	if not current_minigame == null:
		current_minigame.queue_free()
		current_minigame = null


func _load_new_minigame() -> void:
	if not current_minigame == null:
		current_minigame.queue_free()
	current_minigame = minigames[randy.randi_range(0, minigames.size()-1)].instantiate()
	add_child(current_minigame)
	current_minigame.finished.connect(_on_minigame_finished)
	current_minigame.give_points.connect(_on_minigame_give_player_points)
	current_minigame.prepare(players)


func add_player(player_id, device):
	var new_player = Player.new()
	new_player.id = player_id
	new_player.device = device
	players.insert(player_id - 1, new_player)
	get_node("PlayerLabel" + str(player_id)).set_active(true)

	# Add player input into the InputMap
	for i in INPUT_NAMES.size():
		var input_name = "p%s_%s" % [player_id, INPUT_NAMES[i]]

		InputMap.add_action(input_name)

		for button in JOY_BUTTON_INPUTS[i]:
			var ev = InputEventJoypadButton.new()
			ev.button_index = button
			ev.device = device
			InputMap.action_add_event(input_name, ev)

		for joy_axis in JOY_AXIS_INPUTS[i]:
			var ev = InputEventJoypadMotion.new()
			ev.axis = joy_axis[0]
			ev.axis_value = joy_axis[1]
			ev.device = device
			InputMap.action_add_event(input_name, ev)


func remove_player_input(player_id):
	for i in INPUT_NAMES.size():
		var input_name = "p%s_%s" % [player_id, INPUT_NAMES[i]]

		InputMap.erase_action(input_name)
