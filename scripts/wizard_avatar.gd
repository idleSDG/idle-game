# Drop this as a Node2D in any scene where you want to show the wizard.
class_name WizardAvatar
extends Node2D

@export var scale_factor : Vector2 = Vector2(1, 1)

var _visual : WizardVisual

func _ready() -> void:
	var scene = load("res://scenes/wizard_visual.tscn")
	_visual = scene.instantiate()
	_visual.scale = scale_factor
	add_child(_visual)

	# Stay live — refresh whenever equipment or appearance changes
	EquipmentManager.equipment_changed.connect(_visual.refresh)
	PlayerAppearance.appearance_changed.connect(_visual.refresh)
