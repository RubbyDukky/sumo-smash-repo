extends Camera2D

@export var default_strength: float = 5.0
@export var shake_fade_max: float = 12.0
var shake_fade: float = shake_fade_max

var rnd: RandomNumberGenerator = RandomNumberGenerator.new()

var shake_strength: float = 0.0


func apply_shake(strength: float = default_strength, fade_value: float = shake_fade_max) -> void:
	shake_strength = strength
	shake_fade = fade_value


func _process(delta: float) -> void:
	if shake_strength > 0.0:
		shake_strength = lerpf(shake_strength, 0.0, shake_fade * delta)
		
		offset = random_offset()
	if shake_fade < shake_fade_max:
		shake_fade += 0.1


func random_offset() -> Vector2:
	return Vector2(rnd.randf_range(-shake_strength, shake_strength), rnd.randf_range(-shake_strength, shake_strength))
