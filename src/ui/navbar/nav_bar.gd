extends Control

@onready var sections = {
	"home": {
		"upper_label": $VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/AutoSizeLabel2,
		"button": $VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/HomeButton,
		"lower_label": $VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/AutoSizeLabel
	},
	"battle": {
		"upper_label": $VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/AutoSizeLabel2,
		"button": $VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/BattleButton,
		"lower_label": $VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/AutoSizeLabel
	},
	"character": {
		"upper_label": $VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer3/AutoSizeLabel2,
		"button": $VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer3/CharacterButton,
		"lower_label": $VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer3/AutoSizeLabel
	},
	"potions": {
		"upper_label": $VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer4/AutoSizeLabel2,
		"button": $VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer4/PotionsButton,
		"lower_label": $VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer4/AutoSizeLabel
	},
	"shop": {
		"upper_label": $VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer5/AutoSizeLabel2,
		"button": $VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer5/ShopButton,
		"lower_label": $VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer5/AutoSizeLabel
	},
	"settings":{
		"button": %SettingsButton
	}
}	

@export var battle_icon_normal: Texture2D
@export var battle_icon_in_battle: Texture2D

func _ready():
	BattleVariables.battle_state_changed.connect(_on_battle_state_changed)
	_update_battle_button(!(BattleVariables.battleState == BattleVariables.BattleStates.IN_LEVEL_SELECT))
	
	for key in sections:
		sections[key].button.pressed.connect(_on_button_pressed.bind(key))
	
	_on_button_pressed(sections.keys()[0])

func _on_button_pressed(clicked_key: String):
	for key in sections:
		var data = sections[key]
		var is_match = (key == clicked_key)
		if data.has("upper_label") and data.has("lower_label"):
			data.upper_label.visible = !is_match
			data.lower_label.visible = is_match
	
func _on_battle_state_changed(_old_state: BattleVariables.BattleStates, new_state: BattleVariables.BattleStates):
	_update_battle_button(!(new_state == BattleVariables.BattleStates.IN_LEVEL_SELECT))
	
func _update_battle_button(in_battle: bool):
	if in_battle:
		sections.battle.button.icon = battle_icon_in_battle
	else:
		sections.battle.button.icon = battle_icon_normal
