extends State

@export var player: CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
@onready var jump_sound: AudioStreamPlayer2D = player.get_node("JumpSound")


func on_physics_process(delta: float) -> void:
	# slow down
	player.velocity.x = move_toward(player.velocity.x, 0.0, player.decceleration * delta)
	
	player.move_and_slide()
	
	# transition to rise
	if animated_sprite_2d.frame_progress == 1.0:
		player.velocity.y = -player.jump_speed * player.jump_charge_amount
		player.velocity.x = get_movement_axis() * player.run_speed / 3
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
	player.jump_charge_amount = 1.0
