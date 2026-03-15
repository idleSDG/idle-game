extends Node

const SAVE_PATH = "user://spellcraft-idle-save.json"

func _ready():
	if save_file_exists():
		load_game()
	else:
		print("No save file found. Creating new save.")
		init_new_save()

func save_game():
	var save_data = {
		"timestamp": Time.get_unix_time_from_system(),
		"inventory": PlayerInventory.get_save_data(),
		"xp": PlayerProgress.get_save_data()
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(save_data, "\t")
		file.store_string(json_string)
		file.close()
		print("Game Saved.")

func init_new_save():
	PlayerProgress.init_new_save()
	PlayerInventory.init_new_save()

func save_file_exists() -> bool:
	print(FileAccess.file_exists(SAVE_PATH))
	return FileAccess.file_exists(SAVE_PATH)

func load_game():
	print("Loading game.")
	if not save_file_exists():
		print("No save file found.")
		return
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	var data = JSON.parse_string(content)
	if data == null: return

	PlayerInventory.last_inventory_update_unix_time = data.get("timestamp", Time.get_unix_time_from_system())
	if data.has("inventory"):
		PlayerInventory.load_save_data(data["inventory"])
	else:
		printerr("No inventory data found!")

	if data.has("xp"):
		PlayerProgress.load_save_data(data["xp"])
	else:
		printerr("No player xp data found!")

	print("Game Loaded.")
	
func clear_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var dir = DirAccess.open("user://")
		dir.remove(SAVE_PATH)
	init_new_save()

func _notification(what):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
	if what == NOTIFICATION_APPLICATION_FOCUS_IN:
		load_game()
