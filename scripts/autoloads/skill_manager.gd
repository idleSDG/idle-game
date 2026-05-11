extends Node

var skills: Array[Skill] = []

func _ready() -> void:
	#skills[1].equipState = 1
	#skills[2].equipState = 2
	#skills[4].equipState = 3
	pass
	

func Equip(skill : Skill, equipNum : int):
	for sk in skills:
		if sk.equipState == equipNum:
			if skill == null:
				sk.equipState = -1
				return
			
			var oldState = sk.equipState
			sk.equipState = skill.equipState
			skill.equipState = oldState
			return
			
	if skill != null:
		skill.equipState = equipNum
	pass

func get_save_data() -> Dictionary:
	var dict := {}
	var i := 0
	for slot in skills:
		var item = Skill.to_dictionary(slot)
		dict[i] = item
		i += 1
	return { "skills": dict }

func load_save_data(data: Dictionary) -> Error:
	skills.clear()
	for slot_str in data.get("skills"):
		var item := Skill.from_dictionary(data.get("skills")[slot_str])
		if item == null: return ERR_PARSE_ERROR
		skills.append(item)
	return OK

func init_new_save():
	skills = [
		Skill.FromName("Strike"),
		Skill.FromName("Fireball"),
		Skill.FromName("Windstep"),
		Skill.FromName("Chill"),
		Skill.FromName("Chain Lightning"),
	]
	skills[0].equipState = 1
	#skills[2].equipState = 2
	#skills[4].equipState = 3
