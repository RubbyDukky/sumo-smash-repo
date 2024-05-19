extends State

@export var player: CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
@onready var jump_sound: AudioStreamPlayer2D = player.get_node("JumpSound")


func on_physics_process(delta: float) -> void:
	var direction: float = get_movement_axis()
	
	# slow down
	player.velocity.x = move_toward(player.velocity.x, 0.0, player.decceleration * delta)
	
	player.move_and_slide()
	
	# flip sprite
	if direction:
		animated_sprite_2d.flip_h = (direction < 0.0)
	
	# transition to rise
	if animated_sprite_2d.frame_progress == 1.0:
		var jump_vector: Vector2 = Vector2(player.jump_speed_x, -player.jump_speed_y)
		if animated_sprite_2d.flip_h == true:
			jump_vector.x *= -1
		player.velocity = jump_vector
		player.camera.apply_shake(2.0)
		jump_sound.play()
		transition.emit("Rise")
	
	# transition to jump charge
	if animated_sprite_2d.frame == 3 and get_jump_input():
		transition.emit("JumpCharge")


func enter() -> void:
	animated_sprite_2d.play("jump")
	animated_sprite_2d.set_frame(1)
	player.jump_buffer = false
