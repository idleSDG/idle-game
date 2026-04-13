extends Button

var equip : int = -1
@onready var button =  $"."
@onready var border = $TextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func set_up_button(skill : Skill):
	var proper = Skill.DuplicateSkill(skill)
	
	button.icon = proper.sprite
	border.modulate = proper.borderClr
	
	proper.queue_free()
	pass


#func _on_pressed() -> void:
	#equipSkillPressed.emit(equip)
