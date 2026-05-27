extends Control
class_name PostBattlePopup

signal exit_button_pressed()

@onready var title_label: Label = %TitleLabel
@onready var description_label: RichTextLabel = %DescriptionRichTextLabel

@export var victory_header_text: String = "VICTORY!"
@export var defeat_header_text: String = "DEFEAT!"

func _ready() -> void:
	self.visible = false

func show_popup(is_victory: bool) -> void:
	if is_victory:
		title_label.add_theme_color_override("font_color", Color("22d300"))
		title_label.text = victory_header_text
	else:
		title_label.add_theme_color_override("font_color", Color("ff002cff"))
		title_label.text = defeat_header_text
		
	self.visible = true

func _on_exit_button_pressed() -> void:
	exit_button_pressed.emit()
