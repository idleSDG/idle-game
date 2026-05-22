extends Node

const DEFAULT_VOLUME: float = 100

func init_new_save() -> void:
	for index in AudioServer.bus_count:
		AudioServer.set_bus_volume_db(index, DEFAULT_VOLUME)
		AudioServer.set_bus_mute(index, false)

func load_save_data(data: Dictionary) -> Error:
	for index in AudioServer.bus_count:
		var bus_name = AudioServer.get_bus_name(index)
		
		if !data.has(bus_name):
			return ERR_PARSE_ERROR
		
		AudioServer.set_bus_volume_db(index, data[bus_name].volume_db)
		AudioServer.set_bus_mute(index, data[bus_name].is_muted)

	return OK
	
func get_save_data() -> Dictionary:
	var audio_settings_map = {}

	for index in AudioServer.bus_count:
		var bus_name = AudioServer.get_bus_name(index)
		var volume = AudioServer.get_bus_volume_db(index)
		var is_muted = AudioServer.is_bus_mute(index)
		audio_settings_map[bus_name] = {
			"volume_db": volume,
			"is_muted": is_muted
		}
		
	return audio_settings_map
