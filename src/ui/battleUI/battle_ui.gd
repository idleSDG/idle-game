extends Node

@onready var unit_preview: Control = $UnitPreview
@onready var potion_bar: Control = $PotionBar

@onready var hp_bar: ProgressBar = $"UnitPreview/Main Stats/HpBar"
@onready var hp_count: Label = $"UnitPreview/Main Stats/HpBar/HpCount"
@onready var name_field: Label = $"UnitPreview/Main Stats/Name"
@onready var level_count: Label = $"UnitPreview/Main Stats/LevelCount"

@onready var stats_text: RichTextLabel = $UnitPreview/Control2/Stats/VBoxContainer/StatsText
@onready var buffs_text: RichTextLabel = $UnitPreview/Control2/Buffs_Debuffs/VBoxContainer/BuffsText

@onready var button: Button = $PotionBar/HBoxContainer/Button
@onready var button_2: Button = $PotionBar/HBoxContainer/Button2
@onready var button_3: Button = $PotionBar/HBoxContainer/Button3

var potionMem

var char: Character
var charList: Array[Character]


func _ready() -> void:
	pass


func StartPreview(chara: Character):
	unit_preview.visible = true
	char = chara
	potion_bar.visible = false
	UpdateStatDisplay()


func UpdateStatDisplay():
	if (char == null):
		unit_preview.visible = false
		potion_bar.visible = true
		return

	name_field.text = char.charName
	hp_count.text = str(char.statChanges.health) + "/" + str(char.baseStats.maxHealth)
	hp_bar.value = char.statChanges.health * 1.0 / char.baseStats.maxHealth
	level_count.text = "Level " + str(char.level)

	stats_text.text = "[b] STATS[/b]
	[table=2]
[cell][img=32]res://assets/icons/atk.png[/img] Attack:[/cell]      [cell][i]" + str(char.statChanges.attack) + "[/i][/cell]
[cell][img=32]res://assets/icons/def.png[/img] Defense:[/cell]     [cell][i]" + str(char.statChanges.defense) + "[/i][/cell]
[cell][img=32]res://assets/icons/crt.png[/img] Crit Rate:[/cell]   [cell][i]" + str(char.statChanges.critRate) + "[/i][/cell]
[cell][img=32]res://assets/icons/cdm.png[/img] Crit DMG:[/cell]    [cell][i]" + str(char.statChanges.critDMG) + "[/i][/cell]
[cell][img=32]res://assets/icons/chr.png[/img] Charge Rate:  [/cell] [cell][i]" + str(round_place(char.statChanges.chargeRate, 2)) + "[/i][/cell][/table]"

	buffs_text.text = "[b] STATUS EFFECTS[/b][i]"
	var buffs_dict : Dictionary[StatusEffect.StatusEffectType, int] = {}
	for se in char.statusEffects:
		if buffs_dict.has(se.StatusType):
			buffs_dict[se.StatusType] += 1
		else:
			buffs_dict[se.StatusType] = 1
	
	for se in buffs_dict:
		buffs_text.text += "[color=" + StatusEffect.GetClr(se).to_html(false) + "][p]	x" + str(buffs_dict[se]) + " " + StatusEffect.StatusEffectType.keys()[se]

	pass


func SetPotions(pot1: Potion, pot2: Potion, pot3: Potion, charsList: Array[Character]):
	potionMem = BattleVariables.potionUsage.duplicate(true)

	charList = charsList
	button.SetupPotion(pot1, charList, self)
	button_2.SetupPotion(pot2, charList, self)
	button_3.SetupPotion(pot3, charList, self)


func PassTime(delta: float, total: float = 0.0):
	button.PassTime(delta)
	button_2.PassTime(delta)
	button_3.PassTime(delta)

	var newMem: Dictionary

	if potionMem != null:
		for entry in potionMem:
			if potionMem[entry][0] <= total:
				Potion.new(PotionManager.GetPotionSlot(potionMem[entry][1]).id).UsePotionEffect(charList)
				if potionMem[entry][1] == 1:
					button.SetCooldown()
				if potionMem[entry][1] == 2:
					button_2.SetCooldown()
				if potionMem[entry][1] == 3:
					button_3.SetCooldown()
			else:
				newMem[entry] = potionMem[entry]
		potionMem = newMem


func _on_button_pressed() -> void:
	unit_preview.visible = false
	potion_bar.visible = true


func round_place(num, places):
	return (round(num * pow(10, places)) / pow(10, places))
