extends State

@export var player: CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
@onready var jump_buffer_timer: Timer = player.get_node("JumpBufferTimer")
@onready var drop_buffer_timer: Timer = player.get_node("DropBufferTimer")
@onready var land_sound: AudioStreamPlayer2D = player.get_node("LandSound")


func on_physics_process(delta: float) -> void:
	var direction = get_movement_axis()
	# apply acceleration
	if direction:
		player.velocity.x = move_toward(player.velocity.x, player.air_speed * direction, 20.0 * delta)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, player.air_decceleration * delta)
	
	# apply gravity
	if player.velocity.y < player.terminal_velocity:
		player.velocity.y += player.gravity * delta
	
	var prev_velocity_y = player.velocity.y
	
	player.move_and_slide()
	
	# flip sprite
	if direction:
		animated_sprite_2d.flip_h = (direction < 0.0)
	
	# transition to fall
	if player.velocity.y > player.terminal_velocity * 0.7:
		transition.emit("Fall")
	# transition to idle
	elif player.is_on_floor() and !direction:
		if prev_velocity_y > player.terminal_velocity * 0.2:
			player.camera.apply_shake(abs(prev_velocity_y) / 100)
			land_sound.play()
		transition.emit("Idle")
	# transition to run
	elif player.is_on_floor() and direction:
		player.camera.apply_shake(abs(prev_velocity_y) / 100)
		if prev_velocity_y > player.terminal_velocity * 0.15:
			land_sound.play()
		transition.emit("Run")
	
	# handle jump buffer
	if get_jump_input_just_pressed() and !player.jump_buffer:
		player.jump_buffer = true
		player.drop_buffer = false
		jump_buffer_timer.start()
	
	# handle drop buffer
	if get_drop_input_just_pressed() and !player.drop_buffer:
		player.drop_buffer = true
		player.jump_buffer = false
		drop_buffer_timer.start()


func enter() -> void:
	animated_sprite_2d.play("rise")
	land_sound.set_volume_db(-8.0)
	land_sound.set_pitch_scale(1.0)


func exit() -> void:
	animated_sprite_2d.stop()
