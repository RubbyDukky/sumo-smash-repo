extends State

@export var player: CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
@onready var jump_sound: AudioStreamPlayer2D = player.get_node("JumpSound")


func on_physics_process(delta: float) -> void:
	var direction: float = get_movement_axis()
	if get_jump_input():
		if player.jump_charge_amount < 1.5:
			player.jump_charge_amount += 0.008
			print(player.jump_charge_amount)
		else:
			animated_sprite_2d.play("jump_charge_max")
	elif animated_sprite_2d.animation == "jump_charge" or animated_sprite_2d.animation == "jump_charge_max":
		animated_sprite_2d.play("jump")
		animated_sprite_2d.set_frame_and_progress(3, 1.0)
	
	player.camera.apply_shake((player.jump_charge_amount - 1.0) * 4)
	
	# flip sprite
	if direction:
		animated_sprite_2d.flip_h = (direction < 0.0)
	
	# transition to rise
	if animated_sprite_2d.animation == "jump" and animated_sprite_2d.frame_progress == 1.0:
		transition.emit("Rise")


func enter() -> void:
	animated_sprite_2d.play("jump_charge")
	player.jump_charge_amount = 1.0


func exit() -> void:
	animated_sprite_2d.stop()
	var jump_vector: Vector2 = Vector2(player.jump_speed_x, -player.jump_speed_y) * player.jump_charge_amount
	if animated_sprite_2d.flip_h == true:
		jump_vector.x *= -1
	player.velocity = jump_vector
	player.camera.apply_shake(2.0)
	jump_sound.play()
