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
var minigames : Array
var current_minigame : Minigame
@onready var minigames_played := 0
@onready var randy := RandomNumberGenerator.new()
@onready var _animator := $AnimationPlayer as AnimationPlayer
@onready var _timer := $Timer as Timer


func _ready() -> void:
	players = []
	minigames = Array()
	minigames.append(load("res://minigames/click_icons/click_icons.tscn"))
	#var new_player
	#new_player = Player.new()
	#new_player.id = 1
	#new_player.device = -1
	#players.append(new_player)
	#new_player = Player.new()
	#new_player.id = 2
	#new_player.device = -1
	#players.append(new_player)
	#new_player = Player.new()
	#new_player.id = 3
	#new_player.device = -1
	#players.append(new_player)


func _unhandled_input(event : InputEvent):
	# Add players in main menu
	if event.is_action_pressed("start") and not event.is_echo() and current_minigame == null:
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

	elif event.is_action_pressed("ready_up") and not event.is_echo() and current_minigame == null:
		for player in players:
			if player.device == event.device:
				get_node("PlayerLabel" + str(player.id)).is_ready != get_node("PlayerLabel" + str(player.id)).is_ready

	# Forward events to the minigame otherwise
	elif not current_minigame == null:
		var player_id = 0
		for player in players:
			if player.device == event.device:
				player_id = player.id
				break
		current_minigame.handle_input(event, player_id)


func _on_main_menu_pressed_play() -> void:
	if players.size() > -1:
		_animator.play(ANIMATION_CLOSE_SCENE)


func _on_minigame_give_player_points(player_id, points) -> void:
	for player in players:
		if player.id == player_id:
			player.points += points
			break


func _on_minigame_finished() -> void:
	print("minigame finished!")
	minigames_played += 1


func _on_timer_timeout():
	_animator.play(ANIMATION_OPEN_SCENE)



func _on_animation_player_animation_finished(anim_name : String) -> void:
	match anim_name:
		ANIMATION_START_MINIGAME:
			current_minigame.start()

		ANIMATION_CLOSE_SCENE:
			if $MainMenu.is_visible_in_tree():
				$MainMenu.hide()
			_load_new_minigame()
			_timer.start()

		ANIMATION_OPEN_SCENE:
			_animator.play(ANIMATION_START_MINIGAME)


#############################
#   Helper function stuff   #
#############################


func _load_new_minigame() -> void:
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
