extends Node

# General
const MAX_OFFLINE_SECONDS: float = 7.0 * 86400.0
var last_inventory_update_unix_time: float
var inventory_update_timer: Timer

<<<<<<< IG-40-Implement-Cookie-Clicker-Mechanic
# Equipment
var equipment: Array[EquipmentItem] = [EquipmentItem.new("weap1", EquipmentItem.Slot.WEAPON), 
EquipmentItem.new("weap2", EquipmentItem.Slot.WEAPON), EquipmentItem.new("weap3", EquipmentItem.Slot.WEAPON), 
EquipmentItem.new("hat1", EquipmentItem.Slot.HAT), EquipmentItem.new("hat3", EquipmentItem.Slot.HAT), 
EquipmentItem.new("hat2", EquipmentItem.Slot.HAT), EquipmentItem.new("hat4", EquipmentItem.Slot.HAT), 
EquipmentItem.new("robe1", EquipmentItem.Slot.ROBE), EquipmentItem.new("weap4", EquipmentItem.Slot.WEAPON), 
EquipmentItem.new("robe2", EquipmentItem.Slot.ROBE), EquipmentItem.new("hat1", EquipmentItem.Slot.HAT)]
=======
var equipment: Array[EquipmentItem] = [
	EquipmentItem.new("weap1", EquipmentItem.Slot.WEAPON, 0.8), 
	EquipmentItem.new("weap2", EquipmentItem.Slot.WEAPON, 0.6), 
	EquipmentItem.new("weap3", EquipmentItem.Slot.WEAPON, 1.0), 
	EquipmentItem.new("hat1", EquipmentItem.Slot.HAT, 0.0, 0.0, 1.5), 
	EquipmentItem.new("hat3", EquipmentItem.Slot.HAT, 0.0, 0.0, 1.2), 
	EquipmentItem.new("hat2", EquipmentItem.Slot.HAT, 0.0, 0.0, 2.0), 
	EquipmentItem.new("hat4", EquipmentItem.Slot.HAT, 0.0, 0.0, 1.0), 
	EquipmentItem.new("robe1", EquipmentItem.Slot.ROBE, 0.0, 1.5), 
	EquipmentItem.new("weap4", EquipmentItem.Slot.WEAPON, 1.9), 
	EquipmentItem.new("robe2", EquipmentItem.Slot.ROBE, 0.0, 1.7), 
	EquipmentItem.new("hat1", EquipmentItem.Slot.HAT, 0.0, 0.0, 0.5)
	]
>>>>>>> master

# Money System
var money: int
signal money_changed(money: int)

var collectable_money: int
var collectable_money_capacity: int = 25
var collectable_money_progress: float = 0
var collectable_money_gain_rate_seconds: float = 0.0167 
signal collectable_money_changed(collectable_money: int)

# Ingredients
var ingredients: Dictionary[Ingredient.Type, Ingredient] = _create_default_ingredients()
signal ingredients_changed(ingredients: Dictionary[Ingredient.Type, Ingredient])
var _steps_initialized: bool = false
var _screen_time_initialized: bool = false
var _data_ready = [false, false]

class StepsMomentumDataSource:
	extends RefCounted

	func get_latest_value() -> Dictionary:
		return StepsProgress.get_latest_value_for_profile()

	func get_history(start_t: float, end_t: float) -> Array:
		return StepsProgress.get_profile_momentum_history_between(start_t, end_t)
		
class ScreenTimeMomentumDataSource:
	extends RefCounted

	func get_latest_value() -> Dictionary:
		return ScreenTimeProgress.get_latest_value_for_profile()

	func get_history(start_t: float, end_t: float) -> Array:
		return ScreenTimeProgress.get_profile_momentum_history_between(start_t, end_t)

# Used to overwrite values from the save
func _create_default_ingredients() -> Dictionary[Ingredient.Type, Ingredient]:
	return {
		Ingredient.Type.KINETIC_SHARD: Ingredient.new(
			Ingredient.Type.KINETIC_SHARD,
			MomentumTracker.new(MomentumConfig.new(6000.0, 12000.0), StepsMomentumDataSource.new()),
			0.0,
			0,
			10000,
			1.0
		),
		Ingredient.Type.FOCUS_FLUX: Ingredient.new(
			Ingredient.Type.FOCUS_FLUX,
			MomentumTracker.new(MomentumConfig.new(-20, -5), ScreenTimeMomentumDataSource.new()),
			0.0,
			0,
			10000,
			1.0
		)
	}

func _ready():
	_create_timer()
	inventory_update_timer.paused = true

	StepsProgress.steps_data_ready.connect(_on_steps_data_ready)
	if StepsProgress.has_steps_data():
		_on_steps_data_ready()
	ScreenTimeProgress.screen_time_data_ready.connect(_on_screen_time_data_ready)

func _on_steps_data_ready():
	if _steps_initialized:
		return
	_steps_initialized = true
	_set_data_ready(0)

func _on_screen_time_data_ready():
	if _screen_time_initialized:
		return
	_screen_time_initialized = true
	_set_data_ready(1)

func _set_data_ready(material : int):
	_data_ready[material] = true
	if(_data_ready.all(func(boolean): return boolean)):
		_update_inventory()
		inventory_update_timer.paused = false
	
func _create_timer():
	if inventory_update_timer != null:
		return
	inventory_update_timer = Timer.new()
	inventory_update_timer.set_wait_time(0.05)
	inventory_update_timer.connect("timeout", _update_inventory)
	add_child(inventory_update_timer)
	inventory_update_timer.start()

func get_save_data() -> Dictionary:
	var ingredient_map := {}
	for type in ingredients:
		ingredient_map[Ingredient.get_type_as_string(type)] = Ingredient.to_dictionary(ingredients[type])
	
	return { "ingredients": ingredient_map, "money": money, "collectable_money": collectable_money }

func load_save_data(data: Dictionary):
	for entry in data.get("ingredients"):
		var type := Ingredient.get_type_from_string(entry)
		if type == Ingredient.Type.UNKNOWN:
			printerr("Found unknown ingredient type:" + Ingredient.get_type_as_string(type))
		else:
			Ingredient.from_dictionary(ingredients[type], data.get("ingredients")[entry])

	money = data.get("money")
	collectable_money = data.get("collectable_money")
	# First update is delayed until StepsProgress signals readiness.
	ingredients_changed.emit(ingredients)
	money_changed.emit(money)

func init_new_save():
	last_inventory_update_unix_time = Time.get_unix_time_from_system()
	# Reset the ingredients using the ingredient dic
	# TODO: Could load it from a config file or something similar
	ingredients = _create_default_ingredients()
	money = 0
	collectable_money = 3

func _update_inventory():
	var current_inventory_update_unix_time = Time.get_unix_time_from_system()
	var actual_start = max(last_inventory_update_unix_time,current_inventory_update_unix_time - MAX_OFFLINE_SECONDS)
	for type in ingredients:
		ingredients[type].update_progress(actual_start, current_inventory_update_unix_time)
	
	ingredients_changed.emit(ingredients)
	
	var seconds_passed: float = current_inventory_update_unix_time - actual_start
	var collectable_money_to_add: float = collectable_money_gain_rate_seconds * seconds_passed
	collectable_money_progress += collectable_money_to_add
	
	if collectable_money_progress >= 1.0:
		var whole_units = floor(collectable_money_progress)
		collectable_money = clampi(collectable_money + int(whole_units), 0, collectable_money_capacity)
		collectable_money_progress = fmod(collectable_money_progress, 1.0)
	
	money_changed.emit(money)
	collectable_money_changed.emit(collectable_money)
	
	last_inventory_update_unix_time = current_inventory_update_unix_time
