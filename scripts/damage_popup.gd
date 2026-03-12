extends Node2D

@onready var richText = $DamagePopup

var timer = 0.7
var speed = 200.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer -= delta
	self.position += Vector2(0, -1) * delta * speed
	
	if timer < 0:
		self.queue_free()
	
	pass

# Set up created popup with necessary values
func SetUp(pos : Vector2, dmg : int, crit : bool):
	self.position = pos
	
	richText.text = str(dmg) + ("!" if crit else "")
	if crit:
		richText.add_theme_color_override("default_color", Color.RED)
	
	pass
