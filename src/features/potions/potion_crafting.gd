extends Control

const INVENTORY_GRID_COLUMNS: int = 6
const INVENTORY_GRID_ROWS: int = 2

var ingredient_icon_map: Dictionary[Ingredient.Type, Resource] = {
	Ingredient.Type.KINETIC_SHARD: preload("res://assets/icons/ingredients/ingredient_kinetic_shard.tres"),
	Ingredient.Type.FOCUS_FLUX: preload("res://assets/icons/ingredients/ingredient_focus_flux.tres"),
	Ingredient.Type.DREAM_SHARDS: preload("res://assets/icons/ingredients/ingredient_dream_shard.tres"),
} 

@onready var potion_inventory_grid = $VBoxContainer
@onready var _result_item_slot: PotionScreenItemSlot = %ResultItemSlot
@onready var _potion_title: Label = %PotionTitleLabel
@onready var _potion_description: RichTextLabel = %PotionDescriptionRichTextLabel
@onready var _potion_craft_button: IconButton = %PotionCraftButton
@onready var _potion_crafting_slots: Array[PotionScreenItemSlot] = [%CraftingSlot1, %CraftingSlot2]
@onready var _potion_crafting_slot_labels: Array[Label] = [%CraftingSlot1Label, %CraftingSlot2Label]
@onready var sfx_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var craft_sfx: AudioStream

var _selected_potion_index: int = -1

var slot_grid: Array[Array] = []

func _ready() -> void:
	_build_slot_grid()
	_assign_potion_icons()
	PlayerInventory.ingredients_changed.connect(_on_ingredients_changed)

func get_slot_from_index(index: int) -> PotionScreenItemSlot:
	@warning_ignore("integer_division")
	var row = int(index / INVENTORY_GRID_COLUMNS)
	var column = index % INVENTORY_GRID_COLUMNS
	return slot_grid[row][column]

func _build_slot_grid() -> void:
	slot_grid.clear()

	var index := 0

	for row_container in potion_inventory_grid.get_children():
		var row: Array = []

		for slot in row_container.get_children():
			row.append(slot)
			slot.pressed.connect(_on_slot_pressed.bind(index))
			index += 1
			
		slot_grid.append(row)

func _on_ingredients_changed(_ingredients):
	_update_crafting_section(_selected_potion_index)

func _assign_potion_icons() -> void:
	var potions = PotionManager.potions
	for i in range(potions.size()):
		get_slot_from_index(i).icon_texture = potions[i].icon
		get_slot_from_index(i).counter_value = "%s" % potions[i].quantity

func _on_slot_pressed(_slot, index):
	_selected_potion_index = index
	_update_crafting_section(index)
	
func _update_crafting_section(index: int) -> void:
	if index >= len(PotionManager.potions) or index < 0:
		_potion_title.text = "???"
		_potion_description.text = "???"
		_result_item_slot.icon_texture = null
		_result_item_slot.counter_value = "0"
		_potion_craft_button.button_is_disabled = true
		_potion_crafting_slots[0].icon_texture = null
		_potion_crafting_slots[0].counter_value = ""
		_potion_crafting_slot_labels[0].text = "?"
		_potion_crafting_slots[1].icon_texture = null
		_potion_crafting_slots[1].counter_value = ""
		_potion_crafting_slot_labels[1].text = "?"
		return
	
	var potion = PotionManager.potions[index]
	var recipe = potion.recipe[0]
	get_slot_from_index(_selected_potion_index).counter_value = "%s" % potion.quantity
	_potion_title.text = potion.potName
	_result_item_slot.icon_texture = potion.icon
	_result_item_slot.counter_value = "%d" % potion.quantity
	_potion_description.text = potion.recipe_description
	_potion_crafting_slots[0].icon_texture = ingredient_icon_map.get(potion.recipe[0].type)
	_potion_crafting_slots[0].counter_value = "%d / %d" % [PlayerInventory.ingredients[potion.recipe[0].type].count, potion.recipe[0].amount]
	_potion_crafting_slot_labels[0].text = Ingredient.Type.keys()[potion.recipe[0].type].replace("_", " ")
	_potion_crafting_slots[1].icon_texture = ingredient_icon_map.get(potion.recipe[1].type)
	_potion_crafting_slots[1].counter_value = "%d / %d" % [PlayerInventory.ingredients[potion.recipe[1].type].count, potion.recipe[1].amount]
	_potion_crafting_slot_labels[1].text = Ingredient.Type.keys()[potion.recipe[1].type].replace("_", " ")
	
	var can_craft_potion = _can_craft_potion(index)
	_potion_craft_button.button_is_disabled = !can_craft_potion
	
	
func _can_craft_potion(index: int) -> bool:
	var potion = PotionManager.potions[index]
	for i in range(2):
		if PlayerInventory.ingredients[potion.recipe[i].type].count < potion.recipe[i].amount:
			return false
	return true
		
func _on_craft_button_down():
	if _can_craft_potion(_selected_potion_index):
		var potion = PotionManager.potions[_selected_potion_index]
		for i in range(2):
			PlayerInventory.ingredients[potion.recipe[i].type].count -= potion.recipe[i].amount
			PlayerInventory.ingredients_changed.emit(PlayerInventory.ingredients)
			
		potion.quantity += 1
		_potion_crafting_slots[0].counter_value = "%d / %d" % [PlayerInventory.ingredients[potion.recipe[0].type].count, potion.recipe[0].amount]
		_potion_crafting_slots[1].counter_value = "%d / %d" % [PlayerInventory.ingredients[potion.recipe[1].type].count, potion.recipe[1].amount]
		_result_item_slot.counter_value = "%s" % potion.quantity
		get_slot_from_index(_selected_potion_index).counter_value = "%s" % potion.quantity
		
		var can_craft = true
		for i in range(2):
			if PlayerInventory.ingredients[potion.recipe[i].type].count < potion.recipe[i].amount:
				can_craft = false
		if !can_craft:
			_potion_craft_button.button_is_disabled = true
			
		_play_craft_sfx()
		SaveManager.save_game()
		
func _play_craft_sfx():
	sfx_player.stream = craft_sfx
	sfx_player.play()
