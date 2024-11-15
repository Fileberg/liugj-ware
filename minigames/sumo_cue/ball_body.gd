extends CharacterBody2D

func _physics_process(delta: float) -> void:

	var slow_down = move_toward(velocity.length(), 0, delta)
	
	velocity = velocity.normalized() * slow_down

	var collision = move_and_collide(velocity*delta)
	
	if collision != null:
		var collider = collision.get_collider()
		var temp = velocity * 0.5
		velocity = collider.velocity * 0.5
		collider.velocity = temp
