class_name ItemGrid extends Node

@onready var buttonBase = $Button
@onready var grid = $"."

var gridItems = []

func _ready():
	doIngredients()
	pass

func empty_grid():
	for item in gridItems:
		item.queue_free()
	gridItems = []
	pass

func doIngredients():
	empty_grid()
	var list = PlayerInventory.ingredients
	for item in list:
		var newButton = buttonBase.duplicate()
		newButton.visible = true
		grid.add_child(newButton)
		gridItems.append(newButton)
		
		newButton.get_child(0).text = "x" + str(list[item].count)
		newButton.icon = load("res://assets/icons/kinetic.png")
	pass

func doEquipment(slot : EquipmentItem.Slot):
	empty_grid()
	var list = PlayerInventory.equipment
	for item in list:
		if item.slot == slot:
			var newButton = buttonBase.duplicate()
			newButton.visible = true
			grid.add_child(newButton)
			gridItems.append(newButton)
			
			if slot == EquipmentItem.Slot.WEAPON:
				newButton.icon = load("res://assets/icons/staff.png")
			else: if slot == EquipmentItem.Slot.BELT:
				newButton.icon = load("res://assets/icons/robe.png")
			else: 
				newButton.icon = load("res://assets/icons/hat.png")
	pass


func _on_ingredients_pressed() -> void:
	doIngredients()


func _on_hats_pressed() -> void:
	doEquipment(EquipmentItem.Slot.HAT)


func _on_robes_pressed() -> void:
	doEquipment(EquipmentItem.Slot.BELT)


func _on_weapons_pressed() -> void:
	doEquipment(EquipmentItem.Slot.WEAPON)


func _on_potions_pressed() -> void:
	pass # Replace with function body.
