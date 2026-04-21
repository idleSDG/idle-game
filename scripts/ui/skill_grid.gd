class_name SkillGrid extends Node

signal skill_pressed(skill : Skill)
signal equipSkillPressed(equip : int) # SET UP THE THREE MAIN SKILL EQUIP BUTTONS

@onready var buttonBase = $Skill_Grid_Button
@onready var grid = $"."

@export var skillScreen : Control
@export var button1 : SkillGridButton
@export var button2 : SkillGridButton
@export var button3 : SkillGridButton

var currentSelection : int = -1

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
	
	doEquipButton(button1)
	doEquipButton(button2)
	doEquipButton(button3)
	
	var list = SkillManager.skills
	for item in list:
		var newButton = buttonBase.duplicate()
		newButton.visible = true
		grid.add_child(newButton)
		gridItems.append(newButton)
		
		newButton.pressed.connect(inv_skill_Button_Pressed.bind(item))
		
		newButton.set_up_button(item)
	pass

func doEquipButton(equipButton : SkillGridButton):
	for skill in SkillManager.skills:
		if skill.equipState == equipButton.equip:
			equipButton.set_up_equip(skill, true if equipButton.equip == currentSelection else false)
	
	equipButton.pressed.connect(_on_equip_skill_pressed.bind(equipButton.equip))
	pass

func inv_skill_Button_Pressed(skill : Skill):
	skill_pressed.emit(skill)
	if currentSelection == 1 || currentSelection == 2 || currentSelection == 3:
		if BattleVariables.battleState == BattleVariables.BattleStates.IN_LEVEL_SELECT:
			SkillManager.Equip(skill, currentSelection)
	doSkills()


func _on_equip_skill_pressed(equip: int) -> void:
	if currentSelection == equip:
		skillScreen.visible = false
		currentSelection = -1
		doSkills()
		return
	else:
		skillScreen.visible = true
		currentSelection = equip
		doSkills()
		
		for skill in SkillManager.skills:
			if skill.equipState == currentSelection:
				skill_pressed.emit(skill)
	pass
