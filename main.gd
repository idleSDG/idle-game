class_name Main extends Node

@export var home_scene: PackedScene = preload("res://src/features/home/home.tscn")
@export var battle_scene: PackedScene = preload("res://scenes/battle.tscn")
@export var character_scene: PackedScene = preload("res://src/features/characters/character_menu.tscn")
@export var settings_scene: PackedScene = preload("res://scenes/settings.tscn")
@export var inventory_scene: PackedScene = preload("res://scenes/inventory.tscn")

@onready var content_area = $ContentArea
@onready var nav_bar = $"NavBarLayer/NavBar"
@onready var hud_layer = $HUDLayer

var tab_for_button = {
	"HomeButton": "home",
	"BattleButton": "battle",
	"InventoryButton": "inventory",
	"CharacterButton": "character",
	"SettingsButton": "settings",
}

func _ready():
	# Loads save data upon turning the game on and, if the player was in battle, resumes it
	var tab_scenes = {
		"home": home_scene,
		"battle": battle_scene,
		"inventory": inventory_scene,
		"character": character_scene,
		"settings": settings_scene
	}
	SceneManager.setup(content_area, tab_scenes)
	SceneManager.tab_switched.connect(_on_tab_switched)

	SceneManager.switch_tab("home")
	update_navbar_visuals()

func _on_tab_switched(tab_name):
	# Only show HUD on home or battle
	hud_layer.visible = tab_name in ["home", "character"]
	update_navbar_visuals()

func update_navbar_visuals():
	for btn_name in tab_for_button.keys():
		var btn = nav_bar.get_node(btn_name)
		var is_active = SceneManager.current_tab == tab_for_button[btn_name]
		btn.add_theme_font_size_override("font_size", 60 if is_active else 32)
		btn.add_theme_color_override("font_color", Color(0.3, 0.8, 1) if is_active else Color(1, 1, 1))

func _on_home_button_pressed():
	SceneManager.switch_tab("home")

func _on_battle_button_pressed():
	SceneManager.switch_tab("battle")

func _on_equipment_button_pressed():
	SceneManager.switch_tab("equipment")

func _on_inventory_button_pressed():
	SceneManager.switch_tab("inventory")

func _on_settings_button_pressed():
	SceneManager.switch_tab("settings")

func _on_character_button_pressed() -> void:
	SceneManager.switch_tab("character")
