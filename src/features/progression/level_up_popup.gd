class_name LevelUpPopup
extends Control
 
@onready var title_label : Label  = $PanelContainer/MarginContainer/VBox/TitleLabel
@onready var level_label : Label  = $PanelContainer/MarginContainer/VBox/LevelLabel
@onready var stats_label : RichTextLabel  = $PanelContainer/MarginContainer/VBox/StatsLabel
@onready var ok_button   : Button = $PanelContainer/MarginContainer/VBox/OkButton

@onready var v_box: VBoxContainer = $PanelContainer/MarginContainer/VBox
@onready var skill_unlock: HBoxContainer = $PanelContainer/MarginContainer/VBox/HBox_SkillUnlock

@onready var sfx_player = $AudioStreamPlayer2D

@export var confirm_sfx: AudioStream
@export var level_up_sfx: AudioStream

var skillUnlocks = []
 
func _ready() -> void:
	visible = false
	ok_button.pressed.connect(_on_ok_pressed)
	PlayerProgress.leveled_up.connect(_on_leveled_up)
	
func _on_leveled_up(old_level: int, new_level: int) -> void:
	if old_level != new_level:
		show_level_up(old_level, new_level)
 
func show_level_up(old_level: int, new_level: int) -> void:
	_play_level_up_sfx()
	var old_stats = BattleVariables.GetPlayerBaseStatsAtLevel(old_level)
	var new_stats = BattleVariables.GetPlayerBaseStatsAtLevel(new_level)
 
	title_label.text = "^ Level Up! ^"
	if new_level - old_level == 1:
		level_label.text = "You are now level %d!" % new_level
	else:
		level_label.text = "You are now level %d\n(+%d levels!)" % [new_level, new_level - old_level]
 
	#var stats_text = ""
	#stats_text += "HP: %d → %d  (+%d)\n" % [old_stats.maxHealth, new_stats.maxHealth, new_stats.maxHealth - old_stats.maxHealth]
	#stats_text += "ATK: %d → %d  (+%d)\n" % [old_stats.attack,    new_stats.attack,    new_stats.attack    - old_stats.attack]
	#stats_text += "Defense: %d → %d  (+%d)"   % [old_stats.defense,   new_stats.defense,   new_stats.defense   - old_stats.defense]

	var stats_text = "[table=4]
[cell][img=32]res://assets/icons/icon_plus.png[/img][b] HP: [/b][/cell]      [cell][i]" + str(int(old_stats.maxHealth)) + "[/i][/cell] [cell][i]" + "   →   " + "[/i][/cell] [cell][color=#22d300][b][i]" + str(int(new_stats.maxHealth)) + "[/i][/b][/color][/cell]
[cell][img=32]res://assets/icons/atk.png[/img][b] Attack: [/b][/cell]      [cell][i]" + str(int(old_stats.attack)) + "[/i][/cell] [cell][i]" + "   →   " + "[/i][/cell] [cell][color=#22d300][b][i]" + str(int(new_stats.attack)) + "[/i][/b][/color][/cell]
[cell][img=32]res://assets/icons/def.png[/img][b] Defense: [/b][/cell]     [cell][i]" + str(int(old_stats.defense)) + "[/i][/cell] [cell][i]" + "   →   " + "[/i][/cell] [cell][color=#22d300][b][i]" + str(int(new_stats.defense)) + "[/i][/b][/color][/cell] [/table]"

	stats_label.text = stats_text
	visible = true
	
	for s in SkillManager.skills:
		if s.levelRequired > 0 && PlayerProgress.level >= s.levelRequired:
			s.levelRequired = 0
			var newUnlock = skill_unlock.duplicate()
			var proper = Skill.DuplicateSkill(s)
			
			newUnlock.visible = true
			newUnlock.get_child(0).icon = proper.sprite
			newUnlock.get_child(1).text = proper.skillName + " unlocked!"
			skill_unlock.add_sibling(newUnlock)
			skillUnlocks.append(newUnlock)
			
			proper.queue_free()
 
func _on_ok_pressed() -> void:
	visible = false
	_play_confirm_sfx()
	for s in skillUnlocks:
		s.queue_free()
	skillUnlocks.clear()

func _play_confirm_sfx():
	sfx_player.stream = confirm_sfx
	sfx_player.play()
	
func _play_level_up_sfx():
	sfx_player.stream = level_up_sfx
	sfx_player.play()
