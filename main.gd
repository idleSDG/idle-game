extends Node

@onready var content_area = $ContentArea
@onready var home_scene = preload("res://scenes/home.tscn")
@onready var battle_scene = preload("res://scenes/battle.tscn")
@onready var character_scene = preload("res://scenes/character_menu.tscn")
@onready var settings_scene = preload("res://scenes/settings.tscn")
@onready var nav_bar = $"NavBarLayer/NavBar"
@onready var hud_layer = $HUDLayer

var tab_for_button = {
	"HomeButton": "home",
	"BattleButton": "battle",
	"CharacterButton": "character",
	"SettingsButton": "settings",
}

func _ready():
	# Loads save data upon turning the game on and, if the player was in battle, resumes it
	GlobalVariables.load_game()
	if GlobalVariables.inBattle:
		get_tree().change_scene_to_file("res://scenes/battle_area.tscn")
	
	var tab_scenes = {
		"home": home_scene,
		"battle": battle_scene,
		"character": character_scene,
		"settings": settings_scene
	}
	SceneManager.setup(content_area, tab_scenes)
	SceneManager.tab_switched.connect(_on_tab_switched)
	SceneManager.switch_tab("home")
	update_navbar_visuals()

func _on_tab_switched(tab_name):
	# Only show HUD on home or battle
	hud_layer.visible = tab_name in ["home", "battle", "character"]
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

func _on_settings_button_pressed():
	SceneManager.switch_tab("settings")

func _on_character_button_pressed() -> void:
	SceneManager.switch_tab("character")
