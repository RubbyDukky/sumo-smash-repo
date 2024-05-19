extends CharacterBody2D


@export var movement_data: PlayerMovementData

@onready var acceleration: float = movement_data.acceleration
@onready var decceleration: float = movement_data.decceleration
@onready var air_acceleration: float = movement_data.air_acceleration
@onready var air_decceleration: float = movement_data.air_decceleration
@onready var gravity: float = movement_data.gravity
@onready var floating_scale: float = movement_data.floating_scale
@onready var run_speed: float = movement_data.run_speed
@onready var air_speed: float = movement_data.air_speed
@onready var jump_speed_y: float = movement_data.jump_speed_y
@onready var jump_speed_x: float = movement_data.jump_speed_x
@onready var terminal_velocity: float = movement_data.terminal_velocity
@onready var jump_buffer_time: float = movement_data.jump_buffer_time
@onready var drop_buffer_time: float = movement_data.drop_buffer_time

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var drop_buffer_timer: Timer = $DropBufferTimer
@onready var one_way_platform_detector: Area2D = $OneWayPlatformDetector

@onready var jump_charge_amount: float = 1.0
@onready var jump_buffer: bool = false
@onready var drop_buffer: bool = false
@onready var one_way_platform_body: PhysicsBody2D
@onready var camera: Camera2D = get_node("Camera2D")
@onready var bounce_height: float = 0.0
@onready var imaginary_downward_speed: float = 1.0


func _ready() -> void:
	jump_buffer_timer.wait_time = jump_buffer_time
	drop_buffer_timer.wait_time = drop_buffer_time
	jump_buffer_timer.timeout.connect(on_jump_buffer_timeout)
	drop_buffer_timer.timeout.connect(on_drop_buffer_timeout)
	one_way_platform_detector.body_entered.connect(on_one_way_platform_detector_entered)
	one_way_platform_detector.body_exited.connect(on_one_way_platform_detector_exited)


func _physics_process(delta: float) -> void:
	if !is_on_floor() and velocity.y <= 20.0 and velocity.y >= -20.0:
		bounce_height = global_position.y


func reset_camera() -> void:
	camera.position.y = 0.0
	camera.zoom = Vector2(1.0, 1.0)
	camera.limit_left = -54
	camera.limit_right = 391


func on_jump_buffer_timeout() -> void:
	jump_buffer = false


func on_drop_buffer_timeout() -> void:
	drop_buffer = false


func on_one_way_platform_detector_entered(body: PhysicsBody2D) -> void:
	if body.is_in_group("OneWay"):
		one_way_platform_body = body


func on_one_way_platform_detector_exited(body: PhysicsBody2D) -> void:
	if body.is_in_group("OneWay"):
		if one_way_platform_body == body:
			one_way_platform_body = null
		body.set_collision_layer_value(4, true)
