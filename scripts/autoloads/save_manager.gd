extends Node

enum SaveReadError {
	FILE_NOT_FOUND,
	INVALID_SAVE
}

signal save_load_failed(error: SaveReadError)

const SAVE_PATH = "user://spellcraft-idle-save.json"

func _ready():
	load_game.call_deferred()
	if save_file_exists():
		load_game()
	else:
		print("No save file found. Creating new save.")
		init_new_save()

func save_game():
	var save_data = {
		"timestamp": Time.get_unix_time_from_system(),
		"inventory": PlayerInventory.get_save_data(),
		"xp": PlayerProgress.get_save_data(),
		"equipment": EquipmentManager.get_save_data(),
		"appearance": PlayerAppearance.get_save_data(),
		"skills": SkillManager.get_save_data(),
		"battle": BattleVariables.get_save_data()
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
	EquipmentManager.init_new_save()
	PlayerAppearance.init_new_save()
	SkillManager.init_new_save()
	BattleVariables.init_new_save()

func save_file_exists() -> bool:
	print(FileAccess.file_exists(SAVE_PATH))
	return FileAccess.file_exists(SAVE_PATH)

func load_game():
	if not save_file_exists(): 
		save_load_failed.emit(SaveReadError.FILE_NOT_FOUND)
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		save_load_failed.emit(SaveReadError.FILE_NOT_FOUND)
		return
	
	var data = JSON.parse_string(file.get_as_text())
	if not data: 
		save_load_failed.emit(SaveReadError.INVALID_SAVE)
		return

	var systems = {
		"inventory": PlayerInventory,
		"xp": PlayerProgress,
		"equipment": EquipmentManager, 
		"appearance": PlayerAppearance,
		"skills": SkillManager,
		"battle": BattleVariables
	}

	PlayerInventory.last_inventory_update_unix_time = data.get("timestamp", Time.get_unix_time_from_system())

	var invalid_save := false
	for key in systems:
		if not data.has(key): 
			invalid_save = true
			break
			
		var error: Error = systems[key].load_save_data(data[key])
		
		if error != OK:
			invalid_save = true
			printerr("Error when loading %s - %s" % [key, error])
			
	if invalid_save:
		save_load_failed.emit(SaveReadError.INVALID_SAVE)
	
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
