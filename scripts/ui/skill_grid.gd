class_name SkillGrid extends Node

signal skill_pressed(skill : Skill)
signal equipSkillPressed(equip : int) # SET UP THE THREE MAIN SKILL EQUIP BUTTONS

@onready var buttonBase = $Skill_Grid_Button
@onready var grid = $"."

var gridItems = []

func _ready():
	doSkills()
	pass

func empty_grid():
	for item in gridItems:
		item.queue_free()
	gridItems = []
	pass

func doSkills():
	empty_grid()
	var list = SkillManager.skills
	for item in list:
		var newButton = buttonBase.duplicate()
		newButton.visible = true
		grid.add_child(newButton)
		gridItems.append(newButton)
		
		newButton.pressed.connect(inv_skill_Button_Pressed.bind(item))
		
		newButton.set_up_button(item)
	pass

func inv_skill_Button_Pressed(skill : Skill):
	skill_pressed.emit(skill)
	doSkills()
