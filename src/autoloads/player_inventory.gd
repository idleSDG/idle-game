extends Node

# General
const MAX_OFFLINE_SECONDS: float = 7.0 * 86400.0
var last_inventory_update_unix_time: float
var inventory_update_timer: Timer

# Equipment
var equipment: Array[EquipmentItem] = []
signal item_purchased(item: EquipmentItem)

# Money System
var money: int
signal money_changed(money: int)

var collectable_money: int
var collectable_money_capacity: int = 25
var collectable_money_progress: float = 0
var collectable_money_gain_rate_seconds: float = 1.0167
signal collectable_money_changed(collectable_money: int)

# Ingredients
var steps : steps_progress
var screentime : screentime_progress
var sleep : sleep_progress
var step_sleep_manager : steps_sleep_plugin_manager
var ingredients: Dictionary[Ingredient.Type, Ingredient] = {}
signal ingredients_changed(ingredients: Dictionary[Ingredient.Type, Ingredient])
var _steps_initialized: bool = false
var _screen_time_initialized: bool = false
var _sleep_initialized: bool = false
var _data_ready = [false, false, false]

class StepsMomentumDataSource:
	extends RefCounted
	var steps : steps_progress
	
	func _init(step_source : steps_progress) -> void:
		steps = step_source

	func get_latest_value() -> Dictionary:
		return steps.get_latest_value_for_profile()

	func get_history(start_t: float, end_t: float) -> Array:
		return steps.get_profile_momentum_history_between(start_t, end_t)
		
class ScreenTimeMomentumDataSource:
	extends RefCounted
	var screentime : screentime_progress
	
	func	 _init(screentime_source : screentime_progress) -> void:
		screentime = screentime_source

	func get_latest_value() -> Dictionary:
		return screentime.get_latest_value_for_profile()

	func get_history(start_t: float, end_t: float) -> Array:
		return screentime.get_profile_momentum_history_between(start_t, end_t)
		
class SleepMomentumDataSource:
	extends RefCounted
	var sleep : sleep_progress
	
	func _init(sleep_source : sleep_progress) -> void:
		sleep = sleep_source

	func get_latest_value() -> Dictionary:
		return sleep.get_latest_value_for_profile()

	func get_history(start_t: float, end_t: float) -> Array:
		return sleep.get_profile_momentum_history_between(start_t, end_t)

# Used to overwrite values from the save
func _create_default_ingredients() -> Dictionary[Ingredient.Type, Ingredient]:
	return {
		Ingredient.Type.KINETIC_SHARD: Ingredient.new(
			Ingredient.Type.KINETIC_SHARD,
			MomentumTracker.new(MomentumConfig.new(6000.0, 12000.0), StepsMomentumDataSource.new(steps)),
			0.0,
			0,
			10,
			0.1
		),
		Ingredient.Type.FOCUS_FLUX: Ingredient.new(
			Ingredient.Type.FOCUS_FLUX,
			MomentumTracker.new(MomentumConfig.new(-20, -5), ScreenTimeMomentumDataSource.new(screentime)),
			0.0,
			0,
			10,
			0.1
		),
		Ingredient.Type.DREAM_SHARDS: Ingredient.new(
			Ingredient.Type.DREAM_SHARDS,
			MomentumTracker.new(MomentumConfig.new(6.5 * 60, 8.5 * 60), SleepMomentumDataSource.new(sleep)),
			0.0,
			0,
			10,
			0.1
		)
	}

func _ready():
	screentime = screentime_progress.new()
	step_sleep_manager = steps_sleep_plugin_manager.new()
	add_child(step_sleep_manager)
	var classes = step_sleep_manager.get_classes()
	steps = classes[0]
	sleep = classes[1]
	
	ingredients = _create_default_ingredients()
	
	_create_timer()
	inventory_update_timer.paused = true

	steps.steps_data_ready.connect(_on_steps_data_ready)
	if steps.has_steps_data():
		_on_steps_data_ready()
	sleep.sleep_data_ready.connect(_on_sleep_data_ready)
	if sleep.has_sleep_data():
		_on_sleep_data_ready()
	screentime.screen_time_data_ready.connect(_on_screen_time_data_ready)
	if screentime.has_screen_time_data():
		_on_screen_time_data_ready()

func purchase_item(item: EquipmentItem) -> bool:
	if money < item.cost:
		return false
	money -= item.cost
	equipment.append(item)
	money_changed.emit(money)
	item_purchased.emit(item)
	return true

func _on_steps_data_ready():
	if _steps_initialized:
		return
	_steps_initialized = true
	_set_data_ready(0)

func _on_sleep_data_ready():
	if _sleep_initialized:
		return
	_sleep_initialized = true
	_set_data_ready(1)

func _on_screen_time_data_ready():
	if _screen_time_initialized:
		return
	_screen_time_initialized = true
	_set_data_ready(2)

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
	
	# Save purchased item names
	var purchased_names: Array = []
	for item in equipment:
			purchased_names.append(item.item_name)

	return {
		"ingredients": ingredient_map,
		"money": money,
		"collectable_money": collectable_money,
		"purchased_items": purchased_names
	}

func load_save_data(data: Variant) -> Error:
	if typeof(data) != TYPE_DICTIONARY:
		printerr("Load failed: Expected Dictionary, got ", typeof(data))
		return ERR_INVALID_DATA

	if not data.has("ingredients") or typeof(data["ingredients"]) != TYPE_DICTIONARY:
		printerr("Load failed: 'ingredients' key missing or invalid format.")
		return ERR_PARSE_ERROR
	
	var ingredient_data = data["ingredients"]
	for entry_name in ingredient_data:
		var type := Ingredient.get_type_from_string(entry_name)
		
		if type == Ingredient.Type.UNKNOWN:
			printerr("Skipping unknown ingredient type: ", entry_name)
			continue
			
		var entry_payload = ingredient_data[entry_name]
		if typeof(entry_payload) == TYPE_DICTIONARY:
			Ingredient.from_dictionary(ingredients[type], entry_payload)
		else:
			printerr("Invalid data format for ingredient: ", entry_name)
			
	if not data.has("money"):
		printerr("Load failed: Key inventory.money missing or failed to parse.")
		return ERR_PARSE_ERROR
	if not data.has("collectable_money"):
		printerr("Load failed: Key inventory.money missing or failed to parse.")
		return ERR_PARSE_ERROR
	
	money = data.get("money")
	collectable_money = data.get("collectable_money")

	# Restore purchased items from shop catalogue
	equipment = []
	if data.has("purchased_items"):
			for item_name in data["purchased_items"]:
					var item = ShopCatalogue.find_by_name(item_name)
					if item != null:
							equipment.append(item)
					else:
							printerr("Could not find shop item: ", item_name)

	ingredients_changed.emit(ingredients)
	money_changed.emit(money)
	
	return OK

func init_new_save():
	last_inventory_update_unix_time = Time.get_unix_time_from_system()
	# Reset the ingredients using the ingredient dic
	# TODO: Could load it from a config file or something similar
	ingredients = _create_default_ingredients()
	money = 0
	collectable_money = 3
	equipment = []

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
