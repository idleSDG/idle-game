class_name campaign_map

var levels : Array[battle_level]
var paths : Array[battle_path]
var name : String

func _init(p_levels : Array[battle_level], p_name : String, p_generate_paths : bool) -> void:
	levels = []
	paths = []
	p_levels.sort_custom(func(level1 : battle_level, level2 : battle_level): if level1.depth == level2.depth: return level1.position < level2.position else: return level1.depth < level2.depth)
	levels = Array(p_levels)
	name = p_name
	if p_generate_paths:
		generate_paths()
	
func generate_paths() -> void:
	var max_depth = (levels[len(levels) - 1]).depth
	for current_level in levels:
		if(current_level.depth == max_depth):
			break
		var depth = current_level.depth
		for next_level in levels:
			if(depth + 1 == next_level.depth):
				paths.append(battle_path.new(current_level, next_level))
			elif(depth + 2 == next_level.depth):
				break

func get_depth_count() -> Array[int]:
	var max_depth = -1
	for lvl in levels:
		max_depth = max(lvl.depth, max_depth)
	if(max_depth == -1):
		return []
	var depths : Array[int]
	for i in range(max_depth+1):
		depths.append(0)
	for lvl in levels:
		depths[lvl.depth] += 1
	return depths
	
func find_highest_beaten() -> battle_level:
	var highest_level = null
	for level in levels:
		if level.beaten && highest_level == null:
			highest_level = level
		elif highest_level!= null && (level.beaten && level.depth > highest_level.depth):
			highest_level = level
	return highest_level
	
		
static func generate_maps(count : int, depth : int, max_possitions : int) -> Array[campaign_map]:
	var campaigns : Array[campaign_map]
	for i in range(count):
		var campaign_levels : Array[battle_level]
		for j in range(depth):
				for k in range(max(1,randi() % max_possitions)):
					campaign_levels.append(battle_level.new(j,k,false))
		campaigns.append(campaign_map.new(campaign_levels,str(i),true))
	return campaigns	
	
func get_save_data() -> Dictionary:
	var levels_data = []
	for level in levels:
		levels_data.append(level.get_save_data())
	
	var paths_data = []
	for path in paths:
		paths_data.append(path.get_save_data())
		
	return {
		"name" : name,
		"levels" : levels_data,
		"paths" : paths_data
	}
		
	
static func from_save(data: Dictionary) -> campaign_map:
	var p_name = data.get("name", "")
	var loaded_levels : Array[battle_level] = []
	if data.has("levels"):
		for level_data in data["levels"]:
			loaded_levels.append(battle_level.from_save(level_data))
			
	var loaded_campaign = campaign_map.new(loaded_levels,p_name,false)
	
	var loaded_paths : Array[battle_path] = []
	if data.has("paths"):
		for path_data in data["paths"]:
			var p = battle_path.from_save(path_data,loaded_levels)
			if p != null:
				loaded_paths.append(p)
	
	loaded_campaign.paths = loaded_paths
	return loaded_campaign
			
