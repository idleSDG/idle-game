extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("animation_finished", on_finished)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	speed_scale = 2.0 if BattleVariables.isFast else 1.0
	speed_scale = 0.0 if BattleVariables.isPaused else speed_scale
	pass

func on_finished():
	queue_free()

func SetUp(pos: Vector2, type : int, isPlayer : bool = true):
	if BattleVariables.isSimulated:
		queue_free()
		pass
	
	self.position = pos
	scale.x *= 1 if isPlayer else -1
	
	self.position += Vector2(15 * (1 if isPlayer else -1), -50)
	
	match type:
		0: 
			play("explosion")
			scale *= 5.0
			modulate = Color.PALE_GOLDENROD
			pass
		1: 
			play("heal")
			scale *= 2.0
			modulate = Color.SPRING_GREEN
			pass
		2: 
			play("physical")
			scale *= 3.0
			modulate = Color.WHITE
			pass
		3: 
			play("fire1")
			scale *= 3.0
			modulate = Color.ORANGE
			pass
		4: 
			play("wind")
			scale *= 3.0
			modulate = Color.PALE_GREEN
			pass
		5: 
			play("ice")
			scale *= 3.0
			modulate = Color.LIGHT_BLUE
			pass
		6: 
			play("lightning")
			scale *= 3.0
			modulate = Color.PALE_GOLDENROD
			pass

	pass
