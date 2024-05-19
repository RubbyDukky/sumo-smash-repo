extends State

@export var player: CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
@onready var jump_buffer_timer: Timer = player.get_node("JumpBufferTimer")
@onready var drop_buffer_timer: Timer = player.get_node("DropBufferTimer")


func on_physics_process(delta: float) -> void:
	# slow down
	player.velocity.x = move_toward(player.velocity.x, 0.0, player.decceleration * delta)
	
	player.move_and_slide()
	
	# transition to idle
	if animated_sprite_2d.frame_progress == 1.0 and !get_movement_axis():
		transition.emit("Idle")
	# transition to run
	if animated_sprite_2d.frame_progress == 1.0 and get_movement_axis():
		transition.emit("Run")
	# transition to jump
	if animated_sprite_2d.frame_progress == 1.0 and (get_jump_input() or player.jump_buffer):
		transition.emit("Jump")
	
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
	animated_sprite_2d.play("land")
	player.imaginary_downward_speed = 1.0


func exit() -> void:
	animated_sprite_2d.stop()
