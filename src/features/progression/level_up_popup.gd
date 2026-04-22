class_name LevelUpPopup
extends Control
 
@onready var title_label : Label  = $PanelContainer/VBox/TitleLabel
@onready var stats_label : Label  = $PanelContainer/VBox/StatsLabel
@onready var ok_button   : Button = $PanelContainer/VBox/OkButton
 
func _ready() -> void:
	visible = false
	ok_button.pressed.connect(_on_ok_pressed)
 
# Called from hud.gd when leveled_up signal fires
func show_level_up(old_level: int, new_level: int) -> void:
	var old_stats = BattleVariables.GetPlayerStatsAtLevel(old_level)
	var new_stats = BattleVariables.GetPlayerStatsAtLevel(new_level)
 
	if new_level - old_level == 1:
		title_label.text = "Level Up!\nYou are now level %d" % new_level
	else:
		title_label.text = "Level Up!\nYou are now level %d\n(+%d levels!)" % [new_level, new_level - old_level]
 
	var stats_text = ""
	stats_text += "HP: %d → %d  (+%d)\n" % [old_stats.maxHealth, new_stats.maxHealth, new_stats.maxHealth - old_stats.maxHealth]
	stats_text += "ATK: %d → %d  (+%d)\n" % [old_stats.attack,    new_stats.attack,    new_stats.attack    - old_stats.attack]
	stats_text += "Defense: %d → %d  (+%d)"   % [old_stats.defense,   new_stats.defense,   new_stats.defense   - old_stats.defense]
 
	stats_label.text = stats_text
	visible = true
 
func _on_ok_pressed() -> void:
	visible = false
