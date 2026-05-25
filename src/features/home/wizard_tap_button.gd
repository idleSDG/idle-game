extends Button

@export var money_drop_scene: PackedScene

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _on_pressed() -> void:
	if PlayerInventory.collectable_money > 0:
		PlayerInventory.collectable_money -= 1;
		PlayerInventory.collectable_money_changed.emit(PlayerInventory.collectable_money)
		PlayerInventory.money += 1
		var new_confetti = money_drop_scene.instantiate()
		new_confetti.global_position = global_position
		add_child(new_confetti)
		audio_stream_player_2d.pitch_scale = randf_range(0.92, 1.08)
		audio_stream_player_2d.play()
