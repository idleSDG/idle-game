class_name campaign_map

class path:
	var start: level
	var end : level
	func _init(p_start : level, p_end : level) -> void:
		start = p_start
		end = p_end

var levels : Array[level]
var paths : Array[path]
var name : String

func _init(p_levels : Array[level], p_name : String) -> void:
	p_levels.sort_custom(func(level1 : level, level2 : level): return level1.depth < level2.depth)
	levels = Array(p_levels)
	name = p_name
	generate_paths()
	
func generate_paths() -> void:
	var max_depth = (levels[len(levels) - 1]).depth
	for current_level in levels:
		if(current_level.depth == max_depth):
			break
		var depth = current_level.depth
		for next_level in levels:
			if(depth + 1 == next_level.depth):
				paths.append(path.new(current_level, next_level))
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
	
static func generate_maps(count : int, depth : int) -> Array[campaign_map]:
	var campaigns : Array[campaign_map]
	for i in range(count):
		var campaign_levels : Array[level]
		for j in range(depth):
				for k in range(max(1,randi() % 5)):
					campaign_levels.append(level.new(j))
		campaigns.append(campaign_map.new(campaign_levels,str(i)))
	return campaigns
		
