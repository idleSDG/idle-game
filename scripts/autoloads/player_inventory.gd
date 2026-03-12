extends Node

signal ingredients_changed(ingredients: Dictionary[Ingredient.Type, Ingredient])

var ingredients: Dictionary[Ingredient.Type, Ingredient] = {}
@onready var last_timestamp: float
@onready var inventory_update_timer: Timer

const _save_file_path = "user://spellcraft-idle-save.json"

func _ready():
	_load_inventory()
	_create_timer()

func _create_timer():
	if inventory_update_timer != null:
		return
	inventory_update_timer = Timer.new()
	inventory_update_timer.set_wait_time(0.1)
	inventory_update_timer.connect("timeout", _update_inventory)
	add_child(inventory_update_timer)
	inventory_update_timer.start()

func _update_inventory():
	print("Updating inventory...")
	var current_timestamp: float = Time.get_unix_time_from_system()
	
	for type in ingredients:
		ingredients[type].update_progress(last_timestamp, current_timestamp)
	
	ingredients_changed.emit(ingredients)
	last_timestamp = current_timestamp
	print("Inventory updated!")

func _save_inventory():
	print("Saving inventory...")
	
	var save_json_string = JSON.stringify({
		"last_timestamp": Time.get_unix_time_from_system(),
		"ingredients": _get_ingredients_as_array()
	})
	
	print(save_json_string)
	
	var save_file = FileAccess.open(_save_file_path, FileAccess.WRITE)
	if save_file != null:
		save_file.store_string(save_json_string)
		save_file.close()
	else:
		print("Saving failed :(")
	
	print("Saved inventory!")
	
func _get_ingredients_as_array() -> Array:
	var ingredient_list = []
	
	for type_key in ingredients:
		var ingredient = ingredients[type_key]
		ingredient_list.append(Ingredient.to_dictionary(ingredient))
	
	return ingredient_list
	
func _load_inventory():
	print("Loading inventory...")
	
	if not FileAccess.file_exists(_save_file_path):
		_init_new_save()
		_save_inventory()
		return
	
	var file = FileAccess.open(_save_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	var data = JSON.parse_string(content)
	if data == null:
		printerr("Failed to parse save file as JSON.")
		return
	
	ingredients.clear()
	
	last_timestamp = data['last_timestamp']
	
	for entry in data['ingredients']:
		var ingredient = Ingredient.from_dictionary(entry)
		if ingredient:
			ingredients[ingredient.type] = ingredient
		else:
			printerr("Loading ingredient entry failed: %s" % entry)
	
	_update_inventory()
	print("Loaded inventory!")

func _init_new_save() -> void:
	last_timestamp = Time.get_unix_time_from_system()
	ingredients[Ingredient.Type.KINETIC_SHARD] = Ingredient.new(Ingredient.Type.KINETIC_SHARD, 0, 0, 10, 1)

func clear_save() -> void:
	if FileAccess.file_exists(_save_file_path):
		var dir = DirAccess.open("user://")
		dir.remove(_save_file_path)
	_init_new_save()
	_save_inventory()

func _notification(what):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_save_inventory()
		inventory_update_timer.paused = true
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_load_inventory()
		inventory_update_timer.paused = false
