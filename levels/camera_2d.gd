extends Camera2D

@export var default_strength: float = 10.0
@export var shake_fade: float = 12.0

var rnd: RandomNumberGenerator = RandomNumberGenerator.new()

var shake_strength: float = 0.0


func apply_shake(strength: float = default_strength) -> void:
	shake_strength = strength


func _process(delta: float) -> void:
	if shake_strength > 0.0:
		shake_strength = lerpf(shake_strength, 0.0, shake_fade * delta)
		
		offset = random_offset()


func random_offset() -> Vector2:
	return Vector2(rnd.randf_range(-shake_strength, shake_strength), rnd.randf_range(-shake_strength, shake_strength))
