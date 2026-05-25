extends Node

@onready var collectable_money_amount_label = %MoneyCollectionLabel

func _ready():
	PlayerInventory.collectable_money_changed.connect(_on_collectable_money_changed)

func _on_collectable_money_changed(collectable_money: int) -> void:
	collectable_money_amount_label.text = "%d / %d" % [collectable_money, PlayerInventory.collectable_money_capacity]
