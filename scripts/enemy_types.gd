class_name EnemyTypes extends Node

static var character_scene = load("res://scenes/character.tscn")

static func CreateEnemy(id : int) -> Character:
	var char : Character = character_scene.instantiate()
	var stats : CharacterStats

	match id:
		100: 
			stats = CharacterStats.Create(100, 15, 15, 0.25, 1.0, 1.1, 
			 [], [], [], [])
			char.SetStats(stats)
			char.skills.append(Skill.FromName("Chill"))
			
			char.charName = "Wolf"
			char.sprite = load("res://assets/enemies/wolf.png")
		101:
			stats = CharacterStats.Create(120, 10, 20, 0.15, 1.0, 1.0, 
			 [], [], [], [])
			char.SetStats(stats)
			char.skills.append(Skill.FromName("Strike"))
			
			char.charName = "Skeleton"
			char.sprite = load("res://assets/enemies/skeleton.png")
		_: 
			char = null
	
	return char
