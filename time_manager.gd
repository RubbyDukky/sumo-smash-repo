extends Node2D


func _physics_process(delta: float) -> void:
	if Engine.time_scale < 1.0:
		Engine.time_scale += 0.02
	elif Engine.time_scale > 1.0:
		Engine.time_scale = 1.0


func slow_down_time(amount: float) -> void:
	Engine.time_scale -= amount
