class_name Ingredient 

enum Type { KINETIC_SHARD, FOCUS_FLUX, IONIC_CURRENT }

var type: Type
var count: int
var capacity: int
## Defines how much of this ingredient is gained per second, i.e. gain rate of 2 means 2 ingredients made per second.
var gain_rate_per_second: float
## Tracks ingredient gain progress (from 0 to 1).
var progress: float

func _init(p_type: Type, p_progress: float, p_count: int, p_capacity: int, p_gain_rate_per_second: float):
	self.type = p_type
	self.progress = p_progress
	self.count = p_count
	self.capacity = p_capacity
	self.gain_rate_per_second = p_gain_rate_per_second

func update_progress(last_timestamp: float, current_timestamp: float):
	if self.count >= self.capacity:
		self.progress = 0.0
		return
		
	var seconds_passed: float = current_timestamp - last_timestamp
	var units_to_add: float = gain_rate_per_second * seconds_passed
	
	self.progress += units_to_add
	
	if self.progress >= 1.0:
		var whole_units = floor(self.progress)
		self.count = clampi(self.count + int(whole_units), 0, self.capacity)
		self.progress = fmod(self.progress, 1.0)
	
func get_progress_percentage() -> float:
	return self.progress * 100.0
	
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
