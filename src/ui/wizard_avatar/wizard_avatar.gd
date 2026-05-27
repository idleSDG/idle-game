## Drop this as a Node2D in any scene where you want to show the wizard.
class_name WizardAvatar
extends Node2D

@onready var wizard_base_sprite : Sprite2D = $WizardBaseSprite
@onready var skin_sprite   : Sprite2D = $WizardBaseSprite/Skin
@onready var face_sprite   : Sprite2D = $WizardBaseSprite/Face
@onready var hat_sprite    : Sprite2D = $WizardBaseSprite/Hat
@onready var robe_sprite   : Sprite2D = $WizardBaseSprite/Robe
@onready var weapon_sprite : Sprite2D = $WizardBaseSprite/Weapon

func _ready() -> void:
	EquipmentManager.equipment_changed.connect(self.refresh)
	PlayerAppearance.appearance_changed.connect(self.refresh)
	refresh()

func refresh() -> void:
	_apply_appearance()
	_apply_equipment()

func _apply_appearance() -> void:
	skin_sprite.modulate = PlayerAppearance.appearance.skin_color

func _apply_equipment() -> void:
	_apply_slot(hat_sprite, EquipmentItem.Slot.HAT)
	_apply_slot(robe_sprite, EquipmentItem.Slot.ROBE)
	_apply_slot(weapon_sprite, EquipmentItem.Slot.WEAPON)

func _apply_slot(sprite: Sprite2D, slot: EquipmentItem.Slot) -> void:
	var item = EquipmentManager.get_equipped(slot)
	sprite.visible = item != null
	if item:
		sprite.texture = item.sprite