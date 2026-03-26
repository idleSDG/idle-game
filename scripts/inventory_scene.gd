extends Node2D

@onready var nameField = $CanvasLayer/Background/TextureRect/Name
@onready var countField = $CanvasLayer/Background/TextureRect/Count


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_item_grid_equipment_pressed(item: EquipmentItem) -> void:
	nameField.text = item.item_name
	countField.text = "Quantity: 1" 


func _on_item_grid_ingredient_pressed(item: Ingredient) -> void:
	nameField.text = str(Ingredient.Type.find_key(item.type))
	countField.text = "Quantity: " + str(item.count)
