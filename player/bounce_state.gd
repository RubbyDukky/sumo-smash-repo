extends State

@export var player: CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
@onready var jump_buffer_timer: Timer = player.get_node("JumpBufferTimer")
@onready var drop_buffer_timer: Timer = player.get_node("DropBufferTimer")
@onready var land_sound: AudioStreamPlayer2D = player.get_node("LandSound")
@onready var bounce_sound: AudioStreamPlayer2D = player.get_node("BounceSound")

var initial_position_y: float = 0.0


func on_physics_process(delta: float) -> void:
	var prev_velocity_y = player.velocity.y
	var prev_velocity_x = player.velocity.x
	
	var direction = get_movement_axis()
	
	# apply decceleration
	player.velocity.x = move_toward(player.velocity.x, 0.0, player.air_decceleration * delta)
	
	var half_bounce_height = (player.bounce_height + initial_position_y) / 2
	
	# apply gravity when high enough
	if player.global_position.y < half_bounce_height:
		if player.velocity.y < player.terminal_velocity:
			player.velocity.y += player.gravity * delta
	
	var was_on_wall = player.is_on_wall()
	
	player.move_and_slide()
	
	# handle ceiling bounce, transition to fall
	if (player.is_on_ceiling() and prev_velocity_y < -150.0
			and get_bounce_input()):
		bounce_sound.set_volume_db(-8.0 + player.imaginary_downward_speed / 2)
		bounce_sound.set_pitch_scale(1.4 - player.imaginary_downward_speed / 50)
		bounce_sound.play()
		player.velocity.y = min(player.terminal_velocity, -prev_velocity_y)
		player.bounce_height = player.global_position.y
		transition.emit("Fall")
	# transition to rise
	elif player.velocity.y >= 0.0 or player.is_on_ceiling():
		player.bounce_height = player.global_position.y
		transition.emit("Rise")
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
	
	if player.is_on_wall() and !was_on_wall:
		# transition to bounce wall
		if get_bounce_input():
			player.velocity.x = -prev_velocity_x
			animated_sprite_2d.flip_h = (player.velocity.x < 0.0)
			transition.emit("BounceWall")
		# transition to wall slam
		else:
			player.velocity.y *= 0.6
			if abs(prev_velocity_x) > 100.0:
				player.camera.apply_shake(abs(prev_velocity_x) / 75)
				land_sound.play()
				transition.emit("WallSlam")
	
	# handle jump buffer
	if get_jump_input_just_pressed() and !player.jump_buffer:
		player.jump_buffer = true
		player.drop_buffer = false
		jump_buffer_timer.start()
	
	# handle drop buffer
	if (get_crouch_input() and get_jump_input_just_pressed() 
			and !player.drop_buffer):
		player.drop_buffer = true
		player.jump_buffer = false
		drop_buffer_timer.start()


func enter() -> void:
	animated_sprite_2d.play("bounce_ground")
	land_sound.set_volume_db(-8.0)
	land_sound.set_pitch_scale(1.0)
	initial_position_y = player.global_position.y
	player.imaginary_downward_speed = 1.0


func exit() -> void:
	animated_sprite_2d.stop()