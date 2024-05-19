extends State

@export var player: CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = player.get_node("AnimatedSprite2D")


func on_physics_process(delta: float) -> void:
	# run physics
	var direction = get_movement_axis()
	player.velocity.x = move_toward(player.velocity.x, direction * player.run_speed, player.acceleration * delta)
	player.move_and_slide()
	
	animated_sprite_2d.set_speed_scale(max(abs(direction), 0.5))
	
	# flip sprite
	if direction:
		animated_sprite_2d.flip_h = (direction < 0.0)
	# transition to idle
	if !direction:
		transition.emit("Idle")
	# transition to jump
	if get_jump_input() or player.jump_buffer:
		transition.emit("Jump")
	# transition to rise
	elif !player.is_on_floor():
		transition.emit("Rise")
	# transition to crouch
	if player.is_on_floor() and get_crouch_input():
		transition.emit("Crouch")


func enter() -> void:
	animated_sprite_2d.play("run")
	player.imaginary_downward_speed = 1.0


func exit() -> void:
	animated_sprite_2d.stop()
	animated_sprite_2d.set_speed_scale(1.0)
