extends Control

const INVENTORY_GRID_COLUMNS: int = 6
const INVENTORY_GRID_ROWS: int = 2

var ingredient_icon_map: Dictionary[Ingredient.Type, Resource] = {
	Ingredient.Type.KINETIC_SHARD: preload("res://assets/icons/kinetic.png"),
	Ingredient.Type.FOCUS_FLUX: preload("res://assets/icons/triangleTex.png"),
	Ingredient.Type.DREAM_SHARDS: preload("res://assets/icons/staff.png"),
} 

@onready var potion_inventory_grid = $VBoxContainer
@onready var _result_item_slot: PotionScreenItemSlot = %ResultItemSlot
@onready var _potion_title: Label = %PotionTitleLabel
@onready var _potion_description: RichTextLabel = %PotionDescriptionRichTextLabel
@onready var _potion_craft_button: IconButton = %PotionCraftButton
@onready var _potion_crafting_slots: Array[PotionScreenItemSlot] = [%CraftingSlot1, %CraftingSlot2]

var _selected_potion_index: int = -1

var slot_grid: Array[Array] = []

func _ready() -> void:
	_build_slot_grid()
	_assign_potion_icons()
	PlayerInventory.ingredients_changed.connect(_on_ingredients_changed)

func get_slot_from_index(index: int) -> PotionScreenItemSlot:
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

func _on_ingredients_changed(p_):
	_update_crafting_section(_selected_potion_index)

func _assign_potion_icons() -> void:
	var potions = PotionManager.potions
	for i in range(potions.size()):
		get_slot_from_index(i).icon_texture = potions[i].icon
		get_slot_from_index(i).counter_value = "%s" % potions[i].quantity

func _on_slot_pressed(slot, index):
	_selected_potion_index = index
	_update_crafting_section(index)
	
func _update_crafting_section(index: int) -> void:
	if index >= len(PotionManager.potions) or index < 0:
		_potion_title.text = "???"
		_potion_description.text = "???"
		_result_item_slot.icon_texture = null
		_result_item_slot.counter_value = "0"
		_potion_craft_button.is_disabled = true
		_potion_crafting_slots[0].icon_texture = null
		_potion_crafting_slots[0].counter_value = ""
		_potion_crafting_slots[1].icon_texture = null
		_potion_crafting_slots[1].counter_value = ""
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
	_potion_crafting_slots[1].icon_texture = ingredient_icon_map.get(potion.recipe[1].type)
	_potion_crafting_slots[1].counter_value = "%d / %d" % [PlayerInventory.ingredients[potion.recipe[1].type].count, potion.recipe[1].amount]
	
	var can_craft_potion = _can_craft_potion(index)
	_potion_craft_button.is_disabled = !can_craft_potion
	
	
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
			_potion_craft_button.is_disabled = true
		
