extends State

@export var player: CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
@onready var jump_buffer_timer: Timer = player.get_node("JumpBufferTimer")
@onready var drop_buffer_timer: Timer = player.get_node("DropBufferTimer")
@onready var land_sound: AudioStreamPlayer2D = player.get_node("LandSound")
@onready var camera: Camera2D = player.get_node("Camera2D")

var camera_speed: float = 50.0
var camera_offset: float = 60.0

var imaginary_speed: float = 0.0


func _ready() -> void:
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)


func on_physics_process(delta: float) -> void:
	var direction = get_movement_axis()
	# apply acceleration and decceleration
	if direction:
		player.velocity.x = move_toward(player.velocity.x, player.air_speed * direction, player.air_acceleration * delta)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, player.air_decceleration * delta)
	
	# apply gravity
	if player.velocity.y < player.terminal_velocity:
		player.velocity.y += player.gravity * delta * player.floating_scale
	
	var prev_velocity_y = player.velocity.y
	
	player.move_and_slide()
	
	imaginary_speed += 0.1
	
	# move camera
	camera.position.y = move_toward(camera.position.y, camera_offset, camera_speed * delta)
	
	# transition to land
	if player.is_on_floor() and prev_velocity_y >= player.terminal_velocity:
		player.camera.apply_shake(imaginary_speed)
		transition.emit("Land")
	# transition to run
	elif player.is_on_floor() and get_movement_axis():
		player.camera.apply_shake(imaginary_speed)
		transition.emit("Run")
	# transition to idle
	elif player.is_on_floor() and !get_movement_axis():
		player.camera.apply_shake(imaginary_speed)
		transition.emit("Idle")
	
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
	animated_sprite_2d.play("fall")


func exit() -> void:
	camera.position.y = 0.0
	land_sound.set_volume_db(-8.0 + imaginary_speed / 2)
	land_sound.set_pitch_scale(1.0 - imaginary_speed / 100)
	land_sound.play()
	imaginary_speed = 2.0


func _on_animation_finished() -> void:
	if animated_sprite_2d.animation == "fall":
		animated_sprite_2d.play("falling")
