extends State

@export var player: CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = player.get_node("AnimatedSprite2D")


func on_physics_process(delta: float) -> void:
	# slow down
	player.velocity.x = move_toward(player.velocity.x, 0.0, player.decceleration * delta)
	
	player.move_and_slide()
	
	# transition to run
	if get_movement_axis():
		transition.emit("Run")
	# transition to rise
	if !player.is_on_floor():
		transition.emit("Rise")


func enter() -> void:
	animated_sprite_2d.play("jump_down")
	await animated_sprite_2d.animation_finished
	player.one_way_platform_body.set_collision_layer_value(4, false)
