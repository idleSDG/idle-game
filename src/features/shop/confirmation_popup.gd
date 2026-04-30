class_name ConfirmationPopup
extends Control

signal confirmed
signal cancelled

@onready var title_label: Label = $PanelContainer/MarginContainer/VBox/TitleLabel
@onready var message_label: Label = $PanelContainer/MarginContainer/VBox/MessageLabel
@onready var confirm_btn: Button = $PanelContainer/MarginContainer/VBox/HBox/ConfirmBtn
@onready var cancel_btn: Button = $PanelContainer/MarginContainer/VBox/HBox/CancelBtn

func _ready() -> void:
	visible = false
	confirm_btn.pressed.connect(_on_confirm_pressed)
	cancel_btn.pressed.connect(_on_cancel_pressed)

func show_confirmation(title: String, message: String) -> void:
	title_label.text = title
	message_label.text = message
	visible = true

func _on_confirm_pressed() -> void:
	visible = false
	confirmed.emit()

func _on_cancel_pressed() -> void:
	visible = false
	cancelled.emit()
