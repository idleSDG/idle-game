extends Node

var potions: Array[Potion] = []
#var potions: Dictionary[Potion.PotionTypes, int]

func _ready() -> void:
	pass
	

func Equip(skill : Skill, equipNum : int):
	for sk in potions:
		if sk.equipState == equipNum:
			var oldState = sk.equipState
			sk.equipState = skill.equipState
			skill.equipState = oldState
	pass

func get_save_data() -> Dictionary:
	var dict := {}
	var i := 0
	for slot in potions:
		#var item = Potion.to_dictionary(slot)
		#dict[i] = item
		i += 1
	return { "potions": dict }

func load_save_data(data: Dictionary) -> Error:
	potions.clear()
	for slot_str in data.get("potions"):
		var item := Skill.from_dictionary(data.get("potions")[slot_str])
		potions.append(item)
	return OK

func init_new_save():
	potions = [
		Potion.new(Potion.PotionTypes.Healing),
		Potion.new(Potion.PotionTypes.Strength),
		Potion.new(Potion.PotionTypes.Explosive)
	]
	potions[0].equipState = 1
	potions[1].equipState = 2
	potions[2].equipState = 3
