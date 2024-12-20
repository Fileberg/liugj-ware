extends Control

func set_points(points):
	$PointsLabel.text = "Points: " + str(points)


func set_winning(winner : bool) -> void:
	$PointsLabel.label_settings = preload("res://main/winning_points_label.tres") if winner else preload("res://main/points_label.tres")


func set_ready_label(is_ready):
	$PointsLabel.text = "READY" if is_ready else "Not ready"



func set_active(active : bool) -> void:
	if active:
		$PointsLabel.text = "Not Ready"
	else:
		$PointsLabel.text = "Press START"
