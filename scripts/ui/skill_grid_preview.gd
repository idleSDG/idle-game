extends Control

@onready var button =$Button
@onready var border =$Button/TextureRect
@onready var expBar =$Control/ExpBar
@onready var expCount =$Control/ExpBar/ExpCount
@onready var levelCount =$Control/ExpBar/ExpCount/LevelCount
@onready var skillName =$Control/Name
@onready var potency =$Control/Name/Potency
@onready var charge =$Control/Name/Charge
@onready var effects =$Control/Name/Effects

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_preview(skill : Skill):
	var proper := Skill.DuplicateSkill(skill)
	
	skillName.text = skill.skillName
	expBar.value = skill.exp * 1.0 / skill.maxExp
	expCount.text = str(skill.exp) + "/" + str(skill.maxExp)
	levelCount.text = "Level " + str(skill.level) + "/10"
	button.icon = proper.sprite
	border.modulate = proper.borderClr
	potency.text = "Scaling: " + str(int(proper.potency * 100))
	charge.text = "Charge: " + str(int(proper.charge))
	effects.text = "AoE | " if proper.isAoE else ""
	if proper.additionalEffect != null:
		effects.text = effects.text + "Has a " + str(int(proper.additionalEffect.ApplicationRate * 100.0)) + "% chance to apply " + StatusEffect.StatusEffectType.keys()[proper.additionalEffect.StatusType]
	
	proper.queue_free()
	pass


func _on_skill_grid_skill_pressed(skill: Skill) -> void:
	set_preview(skill)
