extends Node

@onready var weapon_container: VBoxContainer = %WeaponsItemList
@onready var robe_container: VBoxContainer = %RobesItemList
@onready var hat_container: VBoxContainer = %HatsItemList
@onready var confirm_popup: ConfirmationPopup = $CanvasLayer/ConfirmationPopup
@onready var sfx_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var buy_sfx: AudioStream

var _card_scene := preload("res://src/features/shop/shop_item_card.tscn")
var _pending_item: EquipmentItem = null


func _ready() -> void:
	_populate()
	confirm_popup.confirmed.connect(_on_purchase_confirmed)
	confirm_popup.cancelled.connect(_on_purchase_cancelled)


func _populate() -> void:
	for item in ShopCatalogue.items:
		var card: ShopItemCard = _card_scene.instantiate()
		match item.slot:
			EquipmentItem.Slot.WEAPON:
				weapon_container.add_child(card)
			EquipmentItem.Slot.ROBE:
				robe_container.add_child(card)
			EquipmentItem.Slot.HAT:
				hat_container.add_child(card)
		card.setup(item)
		card.buy_pressed.connect(_on_buy_pressed)


func _on_buy_pressed(item: EquipmentItem) -> void:
	_pending_item = item
	confirm_popup.show_confirmation(
		"Buy %s" % item.item_name,
		"Purchase %s for %d gold?" % [item.item_name, item.cost],
	)


func _on_purchase_confirmed() -> void:
	if _pending_item == null:
		return
	var success: bool = PlayerInventory.purchase_item(_pending_item)
	if not success:
		# Shouldn't happen since buy button is disabled when broke
		printerr("Purchase failed — insufficient funds")
	_pending_item = null
	_play_buy_sfx()


func _on_purchase_cancelled() -> void:
	_pending_item = null
	
func _play_buy_sfx():
	sfx_player.stream = buy_sfx
	sfx_player.play()
