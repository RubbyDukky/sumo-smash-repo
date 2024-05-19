extends State

@export var player: CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = player.get_node("AnimatedSprite2D")


func on_physics_process(delta: float) -> void:
	# slow down
	player.velocity.x = move_toward(player.velocity.x, 0.0, player.decceleration * delta)
	
	player.move_and_slide()
	
	# transition to idle
	if !get_crouch_input():
		transition.emit("Idle")
	# transition to run
	if !get_crouch_input() and get_movement_axis():
		transition.emit("Run")
	# handle one way platform drop
	if animated_sprite_2d.frame_progress == 1.0:
		if player.one_way_platform_body:
			if get_jump_input_just_pressed() or player.drop_buffer:
				player.one_way_platform_body.set_collision_layer_value(4, false)
				player.drop_buffer = false
				transition.emit("Rise")
		# transition to jump charge
		elif get_jump_input_just_pressed():
			print("changing to jumpcharge")
			transition.emit("JumpCharge")
	# handle drop buffer
	elif player.one_way_platform_body and get_jump_input_just_pressed():
		player.drop_buffer_timer.start()
		player.drop_buffer = true
		player.jump_buffer = false


func enter() -> void:
	animated_sprite_2d.play("jump_down")
