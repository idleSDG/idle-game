class_name Main extends Node

@export var home_scene: PackedScene = preload("res://src/features/home/home.tscn")
@export var battle_scene: PackedScene = preload("res://scenes/battle.tscn")
@export var character_scene: PackedScene = preload("res://src/features/characters/character_menu.tscn")
@export var settings_scene: PackedScene = preload("res://scenes/settings.tscn")
@export var potions_scene: PackedScene = preload("res://src/features/potions/potions_screen.tscn")
@export var shop_scene: PackedScene = preload("res://src/features/shop/shop.tscn")

@onready var content_area = $ContentArea
@onready var hud_layer = $HUDLayer
@onready var ingredient_hud = %SmallIngredientButton

func _ready():
	# Loads save data upon turning the game on and, if the player was in battle, resumes it
	var tab_scenes = {
		"home": home_scene,
		"battle": battle_scene,
		"potions": potions_scene,
		"character": character_scene,
		"shop": shop_scene,
		"settings": settings_scene,
	}
	SceneManager.setup(content_area, tab_scenes)
	SceneManager.tab_switched.connect(_on_tab_switched)

	SceneManager.switch_tab("home")

func _on_tab_switched(tab_name):
	# Only show HUD on home or battle
	hud_layer.visible = tab_name in ["home", "character", "shop", "potions"]
	ingredient_hud.visible = tab_name in ["home", "character", "shop"]

func _on_home_button_pressed():
	SceneManager.switch_tab("home")

func _on_battle_button_pressed():
	SceneManager.switch_tab("battle")

func _on_character_button_pressed():
	SceneManager.switch_tab("character")

func _on_potions_button_pressed():
	SceneManager.switch_tab("potions")

func _on_shop_button_pressed():
	SceneManager.switch_tab("shop")

func _on_settings_button_pressed():
	SceneManager.switch_tab("settings")
