# Handles all appearance and equipment visual updates.
class_name WizardVisual
extends Sprite2D

@onready var skin_sprite   : Sprite2D = $WIZARDSPECIFIC/Skin
@onready var face_sprite   : Sprite2D = $WIZARDSPECIFIC/Face
@onready var hat_sprite    : Sprite2D = $WIZARDSPECIFIC/Hat
@onready var robe_sprite   : Sprite2D = $WIZARDSPECIFIC/Robe
@onready var weapon_sprite : Sprite2D = $WIZARDSPECIFIC/Weapon

func _ready() -> void:
	refresh()

func refresh() -> void:
	_apply_appearance()
	_apply_equipment()

func _apply_appearance() -> void:
	skin_sprite.modulate = PlayerAppearance.appearance.skin_color

func _apply_equipment() -> void:
	hat_sprite.visible    = EquipmentManager.get_equipped(EquipmentItem.Slot.HAT)    != null
	robe_sprite.visible   = EquipmentManager.get_equipped(EquipmentItem.Slot.ROBE)   != null
	weapon_sprite.visible = EquipmentManager.get_equipped(EquipmentItem.Slot.WEAPON) != null
