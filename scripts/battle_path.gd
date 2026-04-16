class_name battle_path

var start: battle_level
var end : battle_level

func _init(p_start : battle_level, p_end : battle_level) -> void:
	start = p_start
	end = p_end

func get_save_data() -> Dictionary:
	return { "start_depth" : start.depth, "start_position" : start.position, "end_depth" : end.depth, "end_position" : end.position}

static func from_save(data : Dictionary, levels : Array[battle_level]) -> battle_path:
	var start_depth = (data["start_depth"] if data.has("start_depth") else 0)
	var start_position = (data["start_position"] if data.has("start_position") else 0)
	var end_depth = (data["end_depth"] if data.has("end_depth") else 0)
	var end_position = (data["end_position"] if data.has("end_position") else 0)
	var start_level = null
	var end_level = null
	for level in levels:
		if level.depth == start_depth && level.position == start_position:
			start_level = level
		if level.depth == end_depth && level.position == end_position:
			end_level = level
	if start_level != null && end_level != null:
		return battle_path.new(start_level, end_level)
	else:
		return null
			
			
	
