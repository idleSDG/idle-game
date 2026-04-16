class_name GlobalVariables extends Object

enum BattleStates { IN_BATTLE, AWAITING_EXIT, IN_LEVEL_SELECT }
static var battleState  : BattleStates = BattleStates.IN_LEVEL_SELECT
static var lastLogin : float = 0
static var battleStart : float = 0
static var currentLogin : float = 0

static var current_battle_level : battle_level
static var current_campaign : String
static var campaigns : Array[campaign_map]

# Dummy player data
static func GetPlayer() -> CharacterStats:
	return CharacterStats.Create(200, 50, 100, 0.5, 1.1, 2.0, [], [], [], [])
	#[0.1, 0.1, 0.1, 0.1, 0.1, 0.1],
	#[0.1, 0.1, 0.1, 0.1, 0.1, 0.1],
	#[0.1, 0.1, 0.1, 0.1, 0.1],
	#[0.1, 0.1, 0.1, 0.1, 0.1])


# Saves data to file in JSON format (%APPDATA%\Roaming\Godot\app_userdata\[project_name])
static func save_game():
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	
	lastLogin = Time.get_unix_time_from_system()
	currentLogin = lastLogin
	
	var save_dict = {
		"battleState": battleState,
		"lastLogin" : lastLogin,
		"battleStart" : battleStart
	}
	var json_string = JSON.stringify(save_dict)
	save_file.store_line(json_string)


# Loads save data from JSON format file (%APPDATA%\Roaming\Godot\app_userdata\[project_name])
static func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return
		
	var i : int = 0
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		# Creates the helper class to interact with JSON.
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse_string(json_string)
		if parse_result == null: #not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		
		var loadedData = parse_result
		battleState = (loadedData["battleState"] if loadedData.has("battleState") else BattleStates.IN_LEVEL_SELECT)
		lastLogin = (loadedData["lastLogin"] if loadedData.has("lastLogin") else Time.get_unix_time_from_system())
		battleStart = (loadedData["battleStart"] if loadedData.has("battleStart") else Time.get_unix_time_from_system())
		currentLogin = Time.get_unix_time_from_system()

static func init_new_battle_save():
	campaigns = campaign_map.generate_maps(3,20,4)
	current_campaign = campaigns[0].name
	current_battle_level = campaigns[0].levels[0]

static func get_campaign_save_data():
	var campaign_data = []
	for campaign in campaigns:
		campaign_data.append(campaign.get_save_data())
	return campaign_data
