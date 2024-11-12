extends Node

const START_MINIGAME_ANIMATION := "start_minigame"

var players : Array[Player]
var minigames : Array
var current_minigame : Minigame
@onready var randy := RandomNumberGenerator.new()


func _ready() -> void:
	players = []
	minigames = Array()
	minigames.append(load("res://minigames/click_icons/click_icons.tscn"))


func _unhandled_input(event : InputEvent):
	# Add players in main menu
	if event.is_action_pressed("start") and not event.is_echo() and current_minigame == null:
		var add_new_player = true
		for player in players:
			if player.device == event.device:
				players.erase(player)
				add_new_player = false
				print("player removed!")
		if add_new_player:
			var player_number := 1
			if players.size() == 0:
				var new_player = preload("res://player/player.tscn").instantiate()
				new_player.number = player_number
				new_player.device = event.device
				players.append(new_player)
				print("new player added!")


func _on_main_menu_pressed_play() -> void:
	$MainMenu.queue_free()
	_load_new_minigame()


func _load_new_minigame() -> void:
	current_minigame = minigames[randy.randi_range(0, minigames.size()-1)].instantiate()
	add_child(current_minigame)
	current_minigame.finished.connect(_on_minigame_finished)
	$AnimationPlayer.play(START_MINIGAME_ANIMATION)


func _on_minigame_finished() -> void:
	print("minigame finished!")


func _on_animation_player_animation_finished(anim_name : String) -> void:
	match anim_name:
		START_MINIGAME_ANIMATION:
			current_minigame.start()
