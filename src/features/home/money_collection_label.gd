extends Label

func _ready():
	PlayerInventory.collectable_money_changed.connect(_on_collectable_money_changed)
	
func _on_collectable_money_changed(collectable_money: int) -> void:
	self.visible = collectable_money > 0
