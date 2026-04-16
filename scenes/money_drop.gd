extends Sprite2D

var velocity: Vector2

func _ready():
	# Randomized "throw" upward and slightly left/right
	velocity = Vector2(randf_range(-150, 150), randf_range(-400, -600))

func _process(delta):
	# 980 is standard Earth gravity; adjust to feel "floaty" or "heavy"
	velocity.y += 1200 * delta 
	position += velocity * delta
	
	# Clean up after it leaves the screen to save memory
	if position.y > get_viewport_rect().size.y + 100:
		queue_free()
