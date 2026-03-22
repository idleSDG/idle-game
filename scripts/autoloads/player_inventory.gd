extends Node

signal ingredients_changed(ingredients: Dictionary[Ingredient.Type, Ingredient])

var ingredients: Dictionary[Ingredient.Type, Ingredient] = {
	Ingredient.Type.KINETIC_SHARD: Ingredient.new(
			Ingredient.Type.KINETIC_SHARD,
			MomentumTracker.new(
				MomentumConfig.new(), 
				DummyMomentumDataSource.new()
			),
			0, 
			0, 
			10, 
			1
		)
}

var last_inventory_update_unix_time: float
var inventory_update_timer: Timer

func _ready():
	_create_timer()

func _notification(what):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		inventory_update_timer.paused = true
	if what == NOTIFICATION_APPLICATION_FOCUS_IN:
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
	
	_update_inventory()

func init_new_save():
	last_inventory_update_unix_time = Time.get_unix_time_from_system()
	# TODO: Load from a config or some other elegant way instead of hard-coding.
	for type in ingredients:
		ingredients[type].count = 0
		ingredients[type].progress = 0
		ingredients[type].capacity = 10

func _update_inventory():
	var current_inventory_update_unix_time = Time.get_unix_time_from_system()
	for type in ingredients:
		ingredients[type].update_progress(last_inventory_update_unix_time, current_inventory_update_unix_time)
	
	ingredients_changed.emit(ingredients)
	last_inventory_update_unix_time = current_inventory_update_unix_time
