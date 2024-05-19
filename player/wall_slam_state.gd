extends State

@export var player: CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
@onready var jump_buffer_timer: Timer = player.get_node("JumpBufferTimer")
@onready var drop_buffer_timer: Timer = player.get_node("DropBufferTimer")


func on_physics_process(delta: float) -> void:
	var direction: float = get_movement_axis()
	# apply gravity
	if player.velocity.y < player.terminal_velocity:
		player.velocity.y += player.gravity * delta * 0.7
	
	player.move_and_slide()
	
	# transition to rise
	if !player.is_on_wall():
		transition.emit("Rise")
	# transition to fall
	if player.velocity.y > player.terminal_velocity * 0.7:
		transition.emit("Fall")
	# transition to idle
	if player.is_on_floor() and !direction:
		transition.emit("Idle")
	# transition to run
	elif player.is_on_floor() and direction:
		transition.emit("Run")
	
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
	animated_sprite_2d.play("wall_slam")
	player.imaginary_downward_speed /= 2.0
	player.bounce_height = player.global_position.y
