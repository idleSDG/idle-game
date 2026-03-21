class_name Ingredient 

enum Type { UNKNOWN, KINETIC_SHARD, FOCUS_FLUX, IONIC_CURRENT }

var type: Type
var count: int
var capacity: int
var gain_rate_per_second: float
var progress: float

var momentum_config: MomentumConfig
var momentum_tracker: MomentumTracker

func _init(p_type: Type, p_momentum_tracker: MomentumTracker, p_progress: float, p_count: int, p_capacity: int, p_gain_rate_per_second: float):
	self.type = p_type
	self.momentum_tracker = p_momentum_tracker
	self.progress = p_progress
	self.count = p_count
	self.capacity = p_capacity
	self.gain_rate_per_second = p_gain_rate_per_second

func get_current_gain_rate() -> float:
	var unix_now = Time.get_unix_time_from_system()
	var momentum = momentum_tracker.get_momentum_at_timestamp(unix_now)
	var bonuses = EquipmentManager.get_total_bonuses()
	var multiplier = 1.0 + bonuses["ingredient_gain_pct"]
	return gain_rate_per_second * multiplier * momentum

func get_effective_gain_rate(last_timestamp: float, current_timestamp: float) -> float:
	var effective_momentum = momentum_tracker.get_time_weighted_multiplier(
		last_timestamp, 
		current_timestamp
	)
	var bonuses = EquipmentManager.get_total_bonuses()
	var multiplier = 1.0 + bonuses["ingredient_gain_pct"]
	return gain_rate_per_second * multiplier * effective_momentum

func update_progress(last_timestamp: float, current_timestamp: float):
	if self.count >= self.capacity:
		self.progress = 0.0
		return
		
	var seconds_passed: float = current_timestamp - last_timestamp
	var effective_momentum = momentum_tracker.get_time_weighted_multiplier(
		last_timestamp, 
		current_timestamp
	)
	var bonuses = EquipmentManager.get_total_bonuses()
	var multiplier = 1.0 + bonuses["ingredient_gain_pct"]
	var units_to_add: float = get_effective_gain_rate(last_timestamp, current_timestamp) * seconds_passed
	
	self.progress += units_to_add
	
	if self.progress >= 1.0:
		var whole_units = floor(self.progress)
		self.count = clampi(self.count + int(whole_units), 0, self.capacity)
		self.progress = fmod(self.progress, 1.0)
	
func get_progress_percentage() -> float:
	return self.progress * 100.0
	
func get_current_momentum_percentage() -> float:
	return self.momentum_tracker.get_momentum_at_timestamp(Time.get_unix_time_from_system()) * 100.0
	
static func to_dictionary(ingredient: Ingredient) -> Dictionary:
	return {
		"progress": ingredient.progress,
		"count": ingredient.count,
		"capacity": ingredient.capacity,
	}
	
static func get_type_as_string(type: Type) -> String:
	return Ingredient.Type.keys()[type]
	
static func get_type_from_string(type_string: String) -> Type:
	if type_string in Type:
		return Type[type_string]
	else:
		return Type.UNKNOWN
	
static func get_type_from_dictionary(dictionary: Dictionary) -> Type:
	var type_string = dictionary.get('type')  
	return get_type_from_string(type_string)
	
static func from_dictionary(p_ingredient: Ingredient, dictionary: Dictionary) -> void:
	p_ingredient.progress = dictionary.get('progress')
	p_ingredient.count = dictionary.get('count')
	p_ingredient.capacity = dictionary.get('capacity')
