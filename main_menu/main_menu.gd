extends Control



signal pressed_play()


func _on_play_button_pressed():
	pressed_play.emit()
