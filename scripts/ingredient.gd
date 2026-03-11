class_name Ingredient 

enum Type { KINETIC_SHARD, FOCUS_FLUX, IONIC_CURRENT }

var type: Type
var progress: float
var count: int
var capacity: int
var gain_rate_per_second: float

func _init(type: Type, progress: float, count: int, capacity: int, gain_rate_per_second: float):
	self.type = type
	self.count = count
	self.capacity = capacity
	self.gain_rate_per_second = gain_rate_per_second

func update_progress(last_timestamp: float, current_timestamp: float):
	if self.count == self.capacity:
		self.progress = 0
		return
		
	var seconds_passed: float = current_timestamp - last_timestamp
	var total_gain = gain_rate_per_second * seconds_passed
	var progress = progress + total_gain
	print("Seconds passed: %f", seconds_passed)
	print("New progress: %f", progress)
	
	if progress >= 100:
		var units_earned = floor(progress / 100)
		self.count = clampi(count + units_earned, 0, self.capacity)
		self.progress = fmod(progress, 100.0)
	else:
		self.progress = progress
	
func get_progress_ratio() -> float:
	return clampf(progress / 100.0, 0.0, 1.0)
	
static func to_dictionary(ingredient: Ingredient) -> Dictionary:
	return {
		"type": Ingredient.Type.keys()[ingredient.type],
		"progress": ingredient.progress,
		"count": ingredient.count,
		"capacity": ingredient.capacity,
		"gain_rate_per_second": ingredient.gain_rate_per_second,
	}
	
static func from_dictionary(dictionary: Dictionary) -> Ingredient:
	var type_string = dictionary.get('type')  
	var type: Type
	if type_string in Type:
		type = Type[type_string]
	else:
		printerr("Unknown ingredient type: ", type_string)
		return null
		
	return Ingredient.new(
		type, 
		dictionary.get('progress'),
		dictionary.get('count'),
		dictionary.get('capacity'),
		dictionary.get('gain_rate_per_second')
	)
