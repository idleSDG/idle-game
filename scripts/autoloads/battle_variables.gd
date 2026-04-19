extends Node

enum BattleStates { IN_BATTLE, AWAITING_EXIT, IN_LEVEL_SELECT }
var battleState  : BattleStates = BattleStates.IN_LEVEL_SELECT
var lastLogin : float = 0
var battleStart : float = 0
var currentLogin : float = 0

func GetPlayer() -> CharacterStats:
	return CharacterStats.Create(500, 15, 100, 0.5, 1.1, 2.0, [], [], [], [])
		
func get_save_data() -> Dictionary:
	return {
		"battleState": battleState,
		"lastLogin" : lastLogin,
		"battleStart" : battleStart
	}
	
func load_save_data(data: Dictionary) -> Error:
	battleState = (data["battleState"] if data.has("battleState") else BattleStates.IN_LEVEL_SELECT)
	lastLogin = (data["lastLogin"] if data.has("lastLogin") else Time.get_unix_time_from_system())
	battleStart = (data["battleStart"] if data.has("battleStart") else Time.get_unix_time_from_system())
	return OK

func init_new_save():
	battleState =  BattleStates.IN_LEVEL_SELECT
	lastLogin = Time.get_unix_time_from_system()
	battleStart =  Time.get_unix_time_from_system()
