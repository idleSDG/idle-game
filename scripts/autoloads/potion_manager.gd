extends Node

var potions: Array[Potion] = []
#var potions: Dictionary[Potion.PotionTypes, int]

func _ready() -> void:
	pass

func GetPotionSlot(slot : int) -> Potion:
	for pot in potions:
		if pot.slot == slot:
			return pot
	return null


func Equip(pot : Potion, equipNum : int):
	for sk in potions:
		if sk.slot == equipNum:
			var oldState = sk.slot
			sk.slot = pot.slot
			pot.slot = oldState
	pass

func get_save_data() -> Dictionary:
	var dict := {}
	var i := 0
	for slot in potions:
		var item = Potion.to_dictionary(slot)
		dict[i] = item
		i += 1
	return { "potions": dict }

func load_save_data(data: Dictionary) -> Error:
	potions.clear()
	for slot_str in data.get("potions"):
		var item := Potion.from_dictionary(data.get("potions")[slot_str])
		potions.append(item)
		pass
	return OK

func init_new_save():
	potions = [
		Potion.new(2, 1),
		Potion.new(0, 2),
		Potion.new(1, 3)
	]
