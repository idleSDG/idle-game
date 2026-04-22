extends Button

@export var money_drop_scene: PackedScene

func _on_pressed() -> void:
	if PlayerInventory.collectable_money > 0:
		PlayerInventory.collectable_money -= 1;
		PlayerInventory.collectable_money_changed.emit(PlayerInventory.collectable_money)
		PlayerInventory.money += 1
		var new_confetti = money_drop_scene.instantiate()
		new_confetti.global_position = global_position
		add_child(new_confetti)
