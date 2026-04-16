class_name EnemyTypes extends Node

static var character_scene = load("res://scenes/character.tscn")
#ELEMENTS 		|| None, Fire, Ice, Lightning, Wind, Physical
#STAT STANDARDS || Health: 100-100000;  Attack: 10-5000;  Defense: 10-5000;

static func CreateEnemy(id : int, level : int = 1) -> Character:
	var char : Character = character_scene.instantiate()
	char.level = level
	var stats : CharacterStats

	match id:
		100: 
			var lv = InterpStats(level, 100, 100000, 20, 7500, 15, 6000)
			stats = CharacterStats.Create(lv.x, lv.y, lv.z, 0.25, 1.0, 1.1, 
			 [0, 0, 0.25, 0, 0, 0], [0, -0.3, 0.2, 0, 0, -0.1], [], []) # weak to Fire
			char.SetStats(stats)
			
			char.skills.append(Skill.FromName("Chill"))
			
			char.charName = "Wolf"
			char.sprite = load("res://assets/enemies/wolf.png")
		101:
			var lv = InterpStats(level, 120, 110000, 15, 5500, 20, 7500)
			stats = CharacterStats.Create(lv.x, lv.y, lv.z, 0.15, 1.0, 1.0, 
			 [0, 0, 0, 0, 0, 0.15], [0, 0, 0, 0.1, -0.3, 0.15], [], []) # weak to Wind
			char.SetStats(stats)
			
			char.skills.append(Skill.FromName("Strike"))
			
			char.charName = "Skeleton"
			char.sprite = load("res://assets/enemies/skeleton.png")
		102:
			var lv = InterpStats(level, 220, 200000, 10, 5100, 15, 6000)
			stats = CharacterStats.Create(lv.x, lv.y, lv.z, 0.35, 0.5, 0.7, 
			 [0, 0, 0, 0, 0.1, 0.1], [0, 0, -0.25, -0.25, 0.1, 0.1], [], []) # weak to Ice and Lightning
			char.SetStats(stats)
			
			char.skills.append(Skill.FromName("Windstep"))
			char.skills.append(Skill.FromName("Strike"))
			
			char.charName = "Big Bird"
			char.sprite = load("res://assets/enemies/bird.png")
		_: 
			char = null
	
	return char

static func InterpStats(level, hp1, hp100, atk1, atk100, def1, def100) -> Vector3:
	var final := Vector3()
	var interpValue = pow((level - 1) / 99.0, 2.8) # scaling, meaning enemies dont scale as much early on
	
	final.x = lerp( hp1,  hp100, interpValue)
	final.y = lerp(atk1, atk100, interpValue)
	final.z = lerp(def1, def100, interpValue)
	
	return final
