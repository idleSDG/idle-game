extends Node

@onready var potion_button: Button = $"."
@onready var quantity: Label = $Quantity
@onready var potname: Label = $Name

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var color_rect: ColorRect = $ColorRect

var potion: Potion
var charList: Array[Character]
var battleUI
var queued = false


func SetupPotion(pot: Potion, list: Array[Character], battUI, posit : Vector2):
	if pot == null:
		potion = null
		quantity.text = ""
		potname.text = "None"
		potion_button.disabled = true
		return

	progress_bar.visible = false
	potion = pot

	quantity.text = "x" + str(PotionManager.GetPotionSlot(potion.slot).quantity)
	potname.text = pot.potName

	charList = list
	battleUI = battUI
	pot.posit = posit

	VerifyPotion()


func PassTime(delta: float):
	if potion == null:
		return

	if queued:
		UsePotion()

	potion.PassTime(delta)
	UpdateVisuals()
	VerifyPotion()


func UpdateVisuals():
	progress_bar.visible = true if potion.currentCooldown > 0 else false

	progress_bar.value = potion.currentCooldown / potion.cooldown
	quantity.text = "x" + str(PotionManager.GetPotionSlot(potion.slot).quantity)
	VerifyPotion()
	pass


func VerifyPotion():
	if (potion.currentCooldown > 0 || PotionManager.GetPotionSlot(potion.slot).quantity < 1):
		potion_button.disabled = true
	else:
		potion_button.disabled = false

func UsePotion():
	potion.UsePotion(charList)
	queued = false
	color_rect.visible = false

	BattleVariables.potionUsage[BattleVariables.potionUsage.size()] = [BattleVariables.battleElapsed, potion.slot]

func SetCooldown():
	potion.currentCooldown = potion.cooldown


func _on_pressed() -> void:
	queued = true
	color_rect.visible = true
	pass # Replace with function body.
