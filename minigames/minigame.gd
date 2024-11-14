class_name Minigame
extends Node

signal finished()
signal give_points(player_id, points)



func prepare(_players : Array) -> void:
	pass


func start() -> void:
	pass


func handle_input(event : InputEvent, player_id):
	pass


func end() -> void:
	finished.emit()
