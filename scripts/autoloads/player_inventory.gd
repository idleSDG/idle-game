extends Node

signal ingredients_changed(ingredients: Dictionary[Ingredient.Type, Ingredient])

var equipment: Array[EquipmentItem] = [EquipmentItem.new("weap1", EquipmentItem.Slot.WEAPON), 
EquipmentItem.new("weap2", EquipmentItem.Slot.WEAPON), EquipmentItem.new("weap3", EquipmentItem.Slot.WEAPON), 
EquipmentItem.new("hat1", EquipmentItem.Slot.HAT), EquipmentItem.new("hat3", EquipmentItem.Slot.HAT), 
EquipmentItem.new("hat2", EquipmentItem.Slot.HAT), EquipmentItem.new("hat4", EquipmentItem.Slot.HAT), 
EquipmentItem.new("robe1", EquipmentItem.Slot.BELT), EquipmentItem.new("weap4", EquipmentItem.Slot.WEAPON), 
EquipmentItem.new("robe2", EquipmentItem.Slot.BELT), EquipmentItem.new("hat1", EquipmentItem.Slot.HAT)]

var ingredients: Dictionary[Ingredient.Type, Ingredient] = {}
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
	inventory_update_timer.set_wait_time(0.1)
	inventory_update_timer.connect("timeout", _update_inventory)
	add_child(inventory_update_timer)
	inventory_update_timer.start()

func get_save_data() -> Dictionary:
	var ingredient_list = []
	for type_key in ingredients:
		ingredient_list.append(Ingredient.to_dictionary(ingredients[type_key]))
	
	return { "ingredients": ingredient_list }

func load_save_data(data: Dictionary):
	ingredients.clear()
	for entry in data.get("ingredients", []):
		var ingredient = Ingredient.from_dictionary(entry)
		if ingredient:
			ingredients[ingredient.type] = ingredient
	
	_update_inventory()

func init_new_save():
	last_inventory_update_unix_time = Time.get_unix_time_from_system()
	ingredients = {
		Ingredient.Type.KINETIC_SHARD: Ingredient.new(Ingredient.Type.KINETIC_SHARD, 0, 0, 10, 0.5)
	}

func _update_inventory():
	var current_inventory_update_unix_time = Time.get_unix_time_from_system()
	for type in ingredients:
		ingredients[type].update_progress(last_inventory_update_unix_time, current_inventory_update_unix_time)
	
	ingredients_changed.emit(ingredients)
	last_inventory_update_unix_time = current_inventory_update_unix_time
