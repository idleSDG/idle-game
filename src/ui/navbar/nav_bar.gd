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
	}
}	

func _ready():
	for key in sections:
		sections[key].button.pressed.connect(_on_button_pressed.bind(key))
	
	_on_button_pressed(sections.keys()[0])

func _on_button_pressed(clicked_key: String):
	for key in sections:
		var data = sections[key]
		var is_match = (key == clicked_key)
		data.upper_label.visible = !is_match
		data.lower_label.visible = is_match
	
