extends AnimatedSprite2D


var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var direction: Vector2
var speed: float


func _ready() -> void:
	direction = Vector2(rng.randf_range(-0.2, 0.2), -rng.randf())
	speed = rng.randf_range(1.0, 2.0)
	get_tree().create_timer(rng.randf_range(0.3, 0.8)).timeout.connect(_on_timer_timeout)
	match rng.randi_range(1, 4):
		1:
			play("particle1")
		2:
			play("particle2")
		3:
			play("particle3")
		4:
			play("particle4")


func _physics_process(delta: float) -> void:
	position += direction * speed


func _on_timer_timeout() -> void:
	queue_free()
