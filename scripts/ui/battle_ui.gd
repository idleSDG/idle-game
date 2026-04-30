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


var char : Character

func StartPreview(chara : Character):
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
	[cell]Attack:[/cell]      [cell][i]" + str(char.statChanges.attack) + "[/i][/cell]
	[cell]Defense:[/cell]     [cell][i]" + str(char.statChanges.defense) + "[/i][/cell]
	[cell]Crit Rate:[/cell]   [cell][i]" + str(char.statChanges.critRate) + "[/i][/cell]
	[cell]Crit DMG:[/cell]    [cell][i]" + str(char.statChanges.critDMG) + "[/i][/cell]
	[cell]Charge Rate:  [/cell] [cell][i]" + str(round_place(char.statChanges.chargeRate, 2)) + "[/i][/cell][/table]"
	
	buffs_text.text = "[b] STATUS EFFECTS[/b][i]"
	for se in char.statusEffects:
		buffs_text.text += "[p]		" + str(se.StatusEffectType.keys()[se.StatusType])
	
	pass

func SetPotions(pot1: Potion, pot2: Potion, pot3: Potion, charList : Array[Character]):
	button.SetupPotion(pot1, charList, self)
	button_2.SetupPotion(pot2, charList, self)
	button_3.SetupPotion(pot3, charList, self)

func PassTime(delta : float):
	button.PassTime(delta)
	button_2.PassTime(delta)
	button_3.PassTime(delta)

func _on_button_pressed() -> void:
	unit_preview.visible = false
	potion_bar.visible = true

func round_place(num, places):
	return (round(num*pow(10,places))/pow(10,places))
