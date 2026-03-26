extends Node

signal ingredients_changed(ingredients: Dictionary[Ingredient.Type, Ingredient])

var equipment: Array[EquipmentItem] = [EquipmentItem.new("weap1", EquipmentItem.Slot.WEAPON), 
EquipmentItem.new("weap2", EquipmentItem.Slot.WEAPON), EquipmentItem.new("weap3", EquipmentItem.Slot.WEAPON), 
EquipmentItem.new("hat1", EquipmentItem.Slot.HAT), EquipmentItem.new("hat3", EquipmentItem.Slot.HAT), 
EquipmentItem.new("hat2", EquipmentItem.Slot.HAT), EquipmentItem.new("hat4", EquipmentItem.Slot.HAT), 
EquipmentItem.new("robe1", EquipmentItem.Slot.ROBE), EquipmentItem.new("weap4", EquipmentItem.Slot.WEAPON), 
EquipmentItem.new("robe2", EquipmentItem.Slot.ROBE), EquipmentItem.new("hat1", EquipmentItem.Slot.HAT)]

const MAX_OFFLINE_SECONDS: float = 7.0 * 86400.0

class StepsMomentumDataSource:
	extends RefCounted

	func get_latest_value() -> Dictionary:
		return StepsProgress.get_latest_value_for_profile()

	func get_history(start_t: float, end_t: float) -> Array:
		return StepsProgress.get_profile_momentum_history_between(start_t, end_t)

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
		)
	}

var ingredients: Dictionary[Ingredient.Type, Ingredient] = _create_default_ingredients()


var last_inventory_update_unix_time: float
var inventory_update_timer: Timer
var _steps_initialized: bool = false

func _ready():
	_create_timer()
	inventory_update_timer.paused = true

	StepsProgress.steps_data_ready.connect(_on_steps_data_ready)
	if StepsProgress.has_steps_data():
		_on_steps_data_ready()

func _on_steps_data_ready():
	if _steps_initialized:
		return
	_steps_initialized = true

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
	
	return { "ingredients": ingredient_map }

func load_save_data(data: Dictionary):
	for entry in data.get("ingredients"):
		var type := Ingredient.get_type_from_string(entry)
		if type == Ingredient.Type.UNKNOWN:
			printerr("Found unknown ingredient type:" + Ingredient.get_type_as_string(type))
		else:
			Ingredient.from_dictionary(ingredients[type], data.get("ingredients")[entry])

	# First update is delayed until StepsProgress signals readiness.
	ingredients_changed.emit(ingredients)

func init_new_save():
	last_inventory_update_unix_time = Time.get_unix_time_from_system()
	# Reset the ingredients using the ingredient dic
	# TODO: Could load it from a config file or something similar
	ingredients = _create_default_ingredients()

func _update_inventory():
	var current_inventory_update_unix_time = Time.get_unix_time_from_system()
	var actual_start = max(last_inventory_update_unix_time,current_inventory_update_unix_time - MAX_OFFLINE_SECONDS)
	for type in ingredients:
		ingredients[type].update_progress(actual_start, current_inventory_update_unix_time)
	
	ingredients_changed.emit(ingredients)
	last_inventory_update_unix_time = current_inventory_update_unix_time
