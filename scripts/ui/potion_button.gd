extends Node

@onready var potion_button: Button = $"."
@onready var quantity: Label = $Quantity
@onready var potname: Label = $Name

@onready var progress_bar: ProgressBar = $ProgressBar
var potion
var currValue = 0

func SetupPotion(pot : Potion):
	progress_bar.visible = false
	
	quantity.text = "x" + str(pot.quantity)
	
	VerifyPotion()

func VerifyPotion():
	if (currValue > 0 || potion.quant < 1):
		potion_button.disabled = true
