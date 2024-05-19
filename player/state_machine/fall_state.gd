extends State

const WIND_PARTICLE = preload("res://player/wind_particle.tscn")

@export var player: CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
@onready var wind_sprite_2d: AnimatedSprite2D = player.get_node("AnimatedSprite2D/WindSprite2D")
@onready var jump_buffer_timer: Timer = player.get_node("JumpBufferTimer")
@onready var drop_buffer_timer: Timer = player.get_node("DropBufferTimer")
@onready var land_sound: AudioStreamPlayer2D = player.get_node("LandSound")
@onready var bounce_sound: AudioStreamPlayer2D = player.get_node("BounceSound")
@onready var wind_sound: AudioStreamPlayer2D = player.get_node("WindSound")
@onready var camera: Camera2D = player.get_node("Camera2D")

var camera_speed: float = 50.0
var camera_offset: float = 100.0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)


func on_physics_process(delta: float) -> void:
	var prev_velocity_y = player.velocity.y
	var prev_velocity_x = player.velocity.x
	
	var direction = get_movement_axis()
	# apply acceleration and decceleration
	if player.imaginary_downward_speed > 5.0:
		var camera_zoom_x: float = move_toward(camera.zoom.x, 0.6, 0.2 * delta)
		var camera_zoom_y: float = move_toward(camera.zoom.y, 0.6, 0.2 * delta)
		camera.zoom = Vector2(camera_zoom_x, camera_zoom_y)
		
		camera.limit_right += 1
		camera.limit_left += -1
		print("L: " + str(camera.limit_left) + " R: " + str(camera.limit_right))
		
		if direction:
			player.velocity.x = move_toward(player.velocity.x, player.air_speed * direction, player.air_acceleration * delta * player.imaginary_downward_speed / 25.0)
		else:
			player.velocity.x = move_toward(player.velocity.x, 0.0, player.air_decceleration * delta)
		
		
	if player.imaginary_downward_speed > 15.0:
		wind_sprite_2d.play("player_wind2")
		if rng.randi_range(1, 10) == 1:
			_create_wind_particle()
	elif player.imaginary_downward_speed > 10.0:
		wind_sprite_2d.play("player_wind1")
		if rng.randi_range(1, 15) == 1:
			_create_wind_particle()
	
	# apply gravity
	if player.velocity.y < player.terminal_velocity:
		player.velocity.y += player.gravity * delta * player.floating_scale
	
	var was_on_wall = player.is_on_wall()
	
	player.move_and_slide()
	
	player.imaginary_downward_speed += 0.1
	
	# wind sound volume
	wind_sound.volume_db = min(5.0, -80.0 + player.imaginary_downward_speed * 3.0)
	
	# move camera
	camera.position.y = move_toward(camera.position.y, camera_offset, camera_speed * delta)
	
	if player.is_on_floor():
		# transition to bounce
		if prev_velocity_y >= player.terminal_velocity:
			if get_bounce_input():
				var bounce_distance = player.bounce_height - player.global_position.y
				var bounce_speed = max(-2 * player.terminal_velocity, -sqrt(-0.6 * player.gravity * bounce_distance))
				player.velocity.y = bounce_speed
				print("bounce! " + str(player.velocity.y))
				player.camera.apply_shake(player.imaginary_downward_speed)
				player.reset_camera()
				if player.imaginary_downward_speed > 10:
					TimeManager.slow_down_time(0.9)
				_play_bounce_sound()
				transition.emit("BounceGround")
			# transition to land
			else:
				player.camera.apply_shake(player.imaginary_downward_speed, min(player.camera.shake_fade_max, 50 / player.imaginary_downward_speed))
				player.reset_camera()
				print(player.imaginary_downward_speed)
				if player.imaginary_downward_speed > 10:
					TimeManager.slow_down_time(0.9)
				_play_land_sound()
				transition.emit("Land")
		# transition to run
		elif get_movement_axis():
			player.camera.apply_shake(player.imaginary_downward_speed)
			player.reset_camera()
			_play_land_sound()
			transition.emit("Run")
		# transition to idle
		elif !get_movement_axis():
			player.camera.apply_shake(player.imaginary_downward_speed)
			player.reset_camera()
			_play_land_sound()
			transition.emit("Idle")
	elif player.is_on_wall() and !was_on_wall:
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
	animated_sprite_2d.play("fall")
	animated_sprite_2d.flip_h = (player.velocity.x < 0)
	wind_sound.play()


func exit() -> void:
	wind_sprite_2d.play("off")
	wind_sound.stop()


func _on_animation_finished() -> void:
	if animated_sprite_2d.animation == "fall":
		animated_sprite_2d.play("falling")


func _play_land_sound() -> void:
	land_sound.set_volume_db(-8.0 + player.imaginary_downward_speed / 2)
	land_sound.set_pitch_scale(1.0 - player.imaginary_downward_speed / 50)
	land_sound.play()


func _play_bounce_sound() -> void:
	bounce_sound.set_volume_db(-8.0 + player.imaginary_downward_speed / 2)
	bounce_sound.set_pitch_scale(1.4 - player.imaginary_downward_speed / 50)
	bounce_sound.play()


func _create_wind_particle() -> void:
	var wind_particle_instance = WIND_PARTICLE.instantiate()
	wind_particle_instance.global_position = player.global_position + Vector2(rng.randf_range(-12.0, 12.0), -5.0)
	get_parent().add_child(wind_particle_instance)
