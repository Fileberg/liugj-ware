extends Control

var points := 0:
	set(new_points):
		points = new_points
		$PointsLabel.text = "Points: " + str(new_points)

var is_ready := false:
	set(new_ready):
		is_ready = new_ready
		$PointsLabel.text = "READY" if new_ready else "Not ready"



func set_active(active : bool) -> void:
	if active:
		$PointsLabel.text = "Not Ready"
		is_ready = false
	else:
		$PointsLabel.text = "Press START"
