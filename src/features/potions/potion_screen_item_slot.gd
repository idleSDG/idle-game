@tool
extends Control
class_name PotionScreenItemSlot

const MAX_COUNTER_VALUE := 99

@export var counter_value: String = "0":
	set(value):
		counter_value = value
		_update_counter()

@export var icon_texture: Texture2D:
	set(value):
		icon_texture = value
		_update_icon()
		
@export var default_icon_texture: Texture2D:
	set(value):
		default_icon_texture = value
		_update_icon()

@onready var _slot_item_counter: Label = %SlotItemCounterLabel
@onready var _slot_item_icon: TextureRect = %SlotItemIcon
@onready var _slot_item_icon_shadow: TextureRect = %SlotItemIconShadow

signal pressed(slot: PotionScreenItemSlot)

func _ready():
	update()

func update():
	_update_counter()
	_update_icon()

func _update_counter():
	if not is_node_ready():
		return

	if _slot_item_counter:
		_slot_item_counter.text = str(counter_value)

func _update_icon():
	if !is_node_ready() || !_slot_item_icon || !_slot_item_icon_shadow:
		return

	if icon_texture:
		_slot_item_icon.texture = icon_texture
		_slot_item_icon.modulate.a = 1
	else:
		_slot_item_icon.texture = default_icon_texture
		_slot_item_icon.modulate.a = 0.5
		
	_slot_item_icon_shadow.texture = _slot_item_icon.texture
		
func _on_button_down():
	pressed.emit(self)
