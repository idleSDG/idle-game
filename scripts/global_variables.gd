class_name GlobalVariables extends Object

var playerDefaults

static func GetPlayer() -> CharacterStats:
	return CharacterStats.Create(100, 50, 100, 0.1, 1.0, 2.0, [], [], [], [])
	#[0.1, 0.1, 0.1, 0.1, 0.1, 0.1],
	#[0.1, 0.1, 0.1, 0.1, 0.1, 0.1],
	#[0.1, 0.1, 0.1, 0.1, 0.1],
	#[0.1, 0.1, 0.1, 0.1, 0.1])
