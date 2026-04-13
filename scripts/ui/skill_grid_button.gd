class_name SkillGridButton extends Button

@export var equip : int = -1
@onready var button =  $"."
@onready var border = $TextureRect
@onready var label = $Label
@onready var color_rect: ColorRect = $ColorRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func set_up_button(skill : Skill):
	var proper = Skill.DuplicateSkill(skill)
	
	if skill.equipState != -1:
		label.visible = true
		label.text = str(skill.equipState)
	
	button.icon = proper.sprite
	border.modulate = proper.borderClr
	
	proper.queue_free()
	pass

func set_up_equip(skill : Skill, selected : bool):
	var proper = Skill.DuplicateSkill(skill)
	
	label.visible = true
	label.text = str(equip)
	button.icon = proper.sprite
	border.modulate = proper.borderClr
	
	color_rect.visible = true if selected else false
	
	proper.queue_free()
	pass

#func _on_pressed() -> void:
	#equipSkillPressed.emit(equip)
