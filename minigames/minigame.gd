class_name Minigame
extends Node

signal finished()



func prepare(_players : Array) -> void:
	pass


func start() -> void:
	pass


func end() -> void:
	finished.emit()
