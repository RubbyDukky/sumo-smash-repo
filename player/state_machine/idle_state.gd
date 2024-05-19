extends State

@export var player: CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = player.get_node("AnimatedSprite2D")


func on_physics_process(delta: float) -> void:
	# slow down
	player.velocity.x = move_toward(player.velocity.x, 0.0, player.decceleration * delta)
	player.move_and_slide()
	
	# transition to run
	if get_movement_axis():
		transition.emit("Run")
	# transition to jump
	if get_jump_input() or player.jump_buffer:
		transition.emit("Jump")
	# transition to rise
	if !player.is_on_floor():
		transition.emit("Rise")
	# transition to crouch
	if player.is_on_floor() and get_crouch_input():
		transition.emit("Crouch")


func enter() -> void:
	animated_sprite_2d.play("idle")
	player.imaginary_downward_speed = 1.0


func exit() -> void:
	animated_sprite_2d.stop()
