class_name EnemyTypes extends Node

static var character_scene = load("res://scenes/character.tscn")
#ELEMENTS :: None, Fire, Ice, Lightning, Wind, Physical


static func CreateEnemy(id : int) -> Character:
	var char : Character = character_scene.instantiate()
	var stats : CharacterStats

	match id:
		100: 
			stats = CharacterStats.Create(100, 20, 15, 0.25, 1.0, 1.1, 
			 [0, 0, 0.25, 0, 0, 0], [0, -0.3, 0.2, 0, 0, -0.1], [], []) # weak to Fire
			char.SetStats(stats)
			
			char.skills.append(Skill.FromName("Chill"))
			
			char.charName = "Wolf"
			char.sprite = load("res://assets/enemies/wolf.png")
		101:
			stats = CharacterStats.Create(120, 15, 20, 0.15, 1.0, 1.0, 
			 [0, 0, 0, 0, 0, 0.15], [0, 0, 0, 0.1, -0.3, 0.15], [], []) # weak to Wind
			char.SetStats(stats)
			
			char.skills.append(Skill.FromName("Strike"))
			
			char.charName = "Skeleton"
			char.sprite = load("res://assets/enemies/skeleton.png")
		102:
			stats = CharacterStats.Create(220, 10, 15, 0.35, 0.5, 0.7, 
			 [0, 0, 0, 0, 0.1, 0.1], [0, 0, -0.25, -0.25, 0.1, 0.1], [], []) # weak to Ice and Lightning
			char.SetStats(stats)
			
			char.skills.append(Skill.FromName("Windstep"))
			char.skills.append(Skill.FromName("Strike"))
			
			char.charName = "Big Bird"
			char.sprite = load("res://assets/enemies/bird.png")
		_: 
			char = null
	
	return char
