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
	
	button.disabled = false
	button.icon = proper.sprite
	border.modulate = proper.borderClr
	
	if skill.levelRequired > PlayerProgress.level:
		button.disabled = true
	
	proper.queue_free()
	pass

func set_up_equip(skill : Skill, selected : bool):
	if skill == null:
		border.modulate = Color.WHITE
		button.icon = null
	else:
		var proper = Skill.DuplicateSkill(skill)

		button.icon = proper.sprite
		border.modulate = proper.borderClr
		proper.queue_free()
	
	label.visible = true
	label.text = str(equip)
	color_rect.visible = true if selected else false
	
	
	pass

#func _on_pressed() -> void:
	#equipSkillPressed.emit(equip)
