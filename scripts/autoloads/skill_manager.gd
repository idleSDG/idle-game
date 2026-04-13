extends Node

var skills: Array[Skill] = []

func _ready() -> void:
	#skills[1].equipState = 1
	#skills[2].equipState = 2
	#skills[4].equipState = 3
	pass

func get_save_data() -> Dictionary:
	var dict := {}
	var i := 0
	for slot in skills:
		var item = Skill.to_dictionary(slot)
		dict[i] = item
		i += 1
	return { "skills": dict }

func load_save_data(data: Dictionary):
	skills.clear()
	for slot_str in data.get("skills"):
		var item := Skill.from_dictionary(data.get("skills")[slot_str])
		skills.append(item)

func init_new_save():
	skills = [
		Skill.FromName("Strike"),
		Skill.FromName("Fireball"),
		Skill.FromName("Windstep"),
		Skill.FromName("Chill"),
		Skill.FromName("Chain Lightning"),
	]
	skills[1].equipState = 1
	skills[2].equipState = 2
	skills[4].equipState = 3
