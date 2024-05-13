extends State

@export var player: CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
@onready var jump_sound: AudioStreamPlayer2D = player.get_node("JumpSound")


func on_physics_process(delta: float) -> void:
	if get_jump_input():
		if player.jump_charge_amount < 100:
			player.jump_charge_amount += 0.003
	else:
		animated_sprite_2d.speed_scale = 1.0
	
	player.camera.apply_shake((player.jump_charge_amount - 1.0) * 4)
	
	# transition to rise
	if animated_sprite_2d.frame_progress == 1.0:
		transition.emit("Rise")


func enter() -> void:
	animated_sprite_2d.speed_scale = 0.0


func exit() -> void:
	animated_sprite_2d.stop()
	player.velocity.y = -player.jump_speed * player.jump_charge_amount
	player.velocity.x = get_movement_axis() * player.run_speed / 3
	player.camera.apply_shake(2.0)
	jump_sound.play()
