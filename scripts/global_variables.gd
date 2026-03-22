class_name GlobalVariables extends Object

static var inBattle = false
static var lastLogin : float = 0
static var currentLogin : float = 0


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
		"inBattle" : inBattle,
		"lastLogin" : lastLogin
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
		inBattle = loadedData["inBattle"]
		lastLogin = loadedData["lastLogin"]
		currentLogin = Time.get_unix_time_from_system()
