class_name campaign_map

enum Type {UNKNOWN, ZOO, SKY, FOREST}

var levels : Array[battle_level]
var paths : Array[battle_path]
var name : String
## Background image of the map
var background_image
## Background color outside the image
var background_color = "FFFFFF"
var type : Type

func _init(p_levels : Array[battle_level], p_name : String, p_generate_paths : bool,
 p_background_image : String, p_background_color : String, p_type : Type) -> void:
	levels = []
	paths = []
	p_levels.sort_custom(func(level1 : battle_level, level2 : battle_level): 
		if level1.depth == level2.depth: return level1.position < level2.position else: return level1.depth < level2.depth)
	levels = Array(p_levels)
	name = p_name
	if p_generate_paths:
		generate_paths()
	background_image = p_background_image
	background_color = p_background_color
	type = p_type
	
func generate_paths() -> void:
	var depths = get_depth_count()
	var max_depth = len(depths) - 1
	
	for current_level in levels:
		if(current_level.depth == max_depth):
			break
	
		var current_depth_level_count = depths[current_level.depth]
		var next_depth_level_count = depths[current_level.depth + 1]
		var next_depth_levels = levels.filter(func(x): return x.depth == current_level.depth+1)
		
		for next_level in next_depth_levels:
			var current_norm = float(current_level.position) / max(current_depth_level_count - 1	, 1)
			var next_norm = float(next_level.position) / max(next_depth_level_count - 1, 1)
			#var closeness = 1.0 - abs(current_norm - next_norm)
			var distance = abs(current_norm - next_norm)
			var probability = exp(-distance * 2.0)
			
			if randf() < probability:	
				paths.append(battle_path.new(current_level, next_level))
		
		if(paths.filter(func(x): return x.start == current_level).is_empty()): # No path out
			var next_connection = randi() % len(next_depth_levels)
			paths.append(battle_path.new(current_level, next_depth_levels[next_connection]))
		
		if(current_level.position == depths[current_level.depth] - 1): # Check for unconnected nodes next depth
			var current_depth_levels = levels.filter(func(x): return x.depth == current_level.depth)
			for next_level in levels.filter(func(x): return x.depth == current_level.depth+1):
				if(paths.filter(func(x): return x.end == next_level).is_empty()):
					var weights : Array[int] = []
					for level in current_depth_levels:
						weights.append((1.0/(abs(max((1.0*level.position/(current_depth_level_count-1))-(1.0*next_level.position/(next_depth_level_count-1)),1.0)))))
					paths.append(battle_path.new(current_depth_levels[RandomNumberGenerator.new().rand_weighted(weights)],next_level))

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
	
		
static func generate_map(depth : int, max_possitions : int, p_name : String, p_background_image : String, 
p_background_color : String, p_type : Type, enemy_types : Array[int], p_enemy_level : int, enemy_count : int) -> campaign_map:
	var campaign_levels : Array[battle_level]
	var weights : Array[Array] = []
	var counts : Array[int] = []
	for i in range(max_possitions):
		var curr_weight : Array[float] = []
		for j in range(max_possitions):
			curr_weight.append(1.0/ pow(1.5,max(abs(i-j),1)))
		weights.append(curr_weight)
		counts.append(i+1)
	var last_count : int = (randi() % max_possitions) + 1
	for i in range(depth):
		last_count = counts[RandomNumberGenerator.new().rand_weighted(weights[last_count-1])]
		for j in range(last_count):
			var enemies : Array[int] = []
			for k in range(enemy_count):
				enemies.append(enemy_types[randi()%len(enemy_types)])
			campaign_levels.append(battle_level.new(i,j,false,enemies,p_enemy_level))

	return campaign_map.new(campaign_levels, p_name,true, p_background_image, p_background_color, p_type)
	
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
		"paths" : paths_data,
		"background_image" : background_image,
		"background_color" : background_color,
		"type" : type}
	
		
	
static func from_save(data: Dictionary) -> campaign_map:
	var p_name = data.get("name", "")
	var loaded_levels : Array[battle_level] = []
	if data.has("levels"):
		for level_data in data["levels"]:
			loaded_levels.append(battle_level.from_save(level_data))
	var p_background_image = (data["background_image"] if data.has("background_image") else "res://assets/battlemap/forest_background.png")
	var p_background_color = (data["background_color"] if data.has("background_color") else "FFFFFF")
	var p_type = (data["type"] if data.has("type") else Type.UNKNOWN)
	var loaded_campaign = campaign_map.new(loaded_levels,p_name,false,p_background_image,p_background_color, p_type)
	
	var loaded_paths : Array[battle_path] = []
	if data.has("paths"):
		for path_data in data["paths"]:
			var p = battle_path.from_save(path_data,loaded_levels)
			if p != null:
				loaded_paths.append(p)
	
	loaded_campaign.paths = loaded_paths
	return loaded_campaign

static func generate_zoo(p_enemy_level : int):
	return campaign_map.generate_map(10,5,"Zoo","res://assets/battlemap/zoo_background.png","116802", Type.ZOO,[100,102],p_enemy_level,min(p_enemy_level*3,10))
	
static func generate_sky(p_enemy_level : int):
	return campaign_map.generate_map(8,4,"Sky","res://assets/battlemap/sky_background.png","9EFDFF", Type.SKY,[101,102],p_enemy_level,min(p_enemy_level*3,10))

static func generate_forest(p_enemy_level : int):
	return campaign_map.generate_map(10,3,"Forest","res://assets/battlemap/forest_background.png","008600", Type.FOREST,[100,101],p_enemy_level,min(p_enemy_level*3,10))
