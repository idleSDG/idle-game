extends Node2D

@onready var richText = $DamagePopup

var timer = 0.7
var speed = 200.0


func _process(delta: float) -> void:
	timer -= delta
	self.position += Vector2(0, -1) * delta * speed
	
	if timer < 0:
		self.queue_free()
	
	pass

# Set up created popup with necessary values
func SetUp(pos : Vector2, dmg : int, crit : bool):
	var rng = RandomNumberGenerator.new()
	self.position = pos + Vector2(rng.randf(), -rng.randf()) * 100
	
	richText.text = str(dmg) + ("!" if crit else "")
	if crit:
		richText.add_theme_color_override("default_color", Color.RED)
	
	pass

func SetUpText(pos : Vector2, dmg : int, text : String, clr : Color):
	var rng = RandomNumberGenerator.new()
	self.position = pos + Vector2(rng.randf(), -rng.randf()) * 100
	
	richText.text = str(dmg) + text if dmg != 0 else text
	richText.add_theme_color_override("default_color", clr)
	
	pass
