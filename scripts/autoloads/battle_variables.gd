extends Node

enum BattleStates { IN_BATTLE, AWAITING_EXIT, IN_LEVEL_SELECT }
var battleState  : BattleStates = BattleStates.IN_LEVEL_SELECT
var lastLogin : float = 0
var battleStart : float = 0
var currentLogin : float = 0

var current_battle_level : battle_level
var current_campaign : String
var campaigns : Array[campaign_map]

func GetPlayer() -> CharacterStats:
	return CharacterStats.Create(500, 15, 100, 0.5, 1.1, 2.0, [], [], [], [])
		
func get_save_data() -> Dictionary:
	return {
		"battleState": battleState,
		"lastLogin" : lastLogin,
		"battleStart" : battleStart,
		"campaigns": get_campaign_save_data(),
		"current_campaign": current_campaign,
		"current_battle_level": current_battle_level.get_save_data() if current_battle_level != null else {}
	}
	
func load_save_data(data: Dictionary) -> Error:
	battleState = (data["battleState"] if data.has("battleState") else BattleStates.IN_LEVEL_SELECT)
	lastLogin = (data["lastLogin"] if data.has("lastLogin") else Time.get_unix_time_from_system())
	battleStart = (data["battleStart"] if data.has("battleStart") else Time.get_unix_time_from_system())
	if data.has("campaigns"):
		campaigns = []
		for campaign_data in data["campaigns"]:
			campaigns.append(campaign_map.from_save(campaign_data))
			
		if data.has("current_campaign"):
			current_campaign = data["current_campaign"]
			if data.has("current_battle_level"):
				var loaded_level = battle_level.from_save(data["current_battle_level"])
				for campaign in campaigns:
					if(campaign.name == current_campaign):
						for level in campaign.levels:
							if level.depth == loaded_level.depth && level.position == loaded_level.position:
								current_battle_level = level
			else:
				return ERR_PARSE_ERROR
		else:
			return ERR_PARSE_ERROR
	else:
		return ERR_PARSE_ERROR
	return OK

func init_new_save():
	battleState =  BattleStates.IN_LEVEL_SELECT
	lastLogin = Time.get_unix_time_from_system()
	battleStart =  Time.get_unix_time_from_system()
	
	campaigns = []
	campaigns.append(campaign_map.generate_zoo(1))
	campaigns.append(campaign_map.generate_forest(1))
	campaigns.append(campaign_map.generate_sky(1))
	
	current_campaign = campaigns[0].name
	current_battle_level = campaigns[0].levels[0]
	

func get_campaign_save_data():
	var campaign_data = []
	for campaign in campaigns:
		campaign_data.append(campaign.get_save_data())
	return campaign_data
