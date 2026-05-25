@tool
extends Button

class_name TextIconButton

const DEFAULT_PATCH_MARGIN := 64
const DEFAULT_ICON_SIZE := Vector2(64.0, 64.0)

var container_height = 0

@export var button_is_disabled: bool = false:
	set(value):
		button_is_disabled = value
		disabled = value
		_update_visuals()

@export var left_icon: Texture2D:
	set(value):
		left_icon = value
		if is_node_ready():
			_update_icons()

@export var right_icon: Texture2D:
	set(value):
		right_icon = value
		if is_node_ready():
			_update_icons()

@export var button_text: String = "Button":
	set(value):
		button_text = value
		if is_node_ready():
			_update_label()

@export var text_color: Color = "000000":
	set(value):
		text_color = value
		if is_node_ready():
			_update_label()

@export var label_font: Font:
	set(value):
		label_font = value
		if is_node_ready():
			_update_label()

@export var label_font_size: int = 16:
	set(value):
		label_font_size = value
		if is_node_ready():
			_update_label()

@export var patch_margin: int = DEFAULT_PATCH_MARGIN:
	set(value):
		patch_margin = value
		if is_node_ready():
			_update_nine_patches()

@export var icon_size: Vector2 = DEFAULT_ICON_SIZE:
	set(value):
		icon_size = value
		if is_node_ready():
			_update_icons()

@export var normal_texture: Texture2D:
	set(value):
		normal_texture = value
		if is_node_ready():
			_update_nine_patches()

@export var pressed_texture: Texture2D:
	set(value):
		pressed_texture = value
		if is_node_ready():
			_update_nine_patches()


func _ready() -> void:
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		add_theme_stylebox_override(state, StyleBoxEmpty.new())
	_update_icons()
	_update_label()
	_update_nine_patches()


func _update_icons() -> void:
	var left := get_node_or_null("ContentContainer/LeftMarginContainer/LeftIcon") as TextureRect
	var right := get_node_or_null("ContentContainer/RightMarginContainer/RightIcon") as TextureRect
	var left_parent := get_node_or_null("ContentContainer/LeftMarginContainer") as MarginContainer
	var right_parent := get_node_or_null("ContentContainer/RightMarginContainer") as MarginContainer

	if left:
		left.texture = left_icon
		left_parent.visible = left_icon != null
		left.custom_minimum_size = icon_size
	if right:
		right.texture = right_icon
		right_parent.visible = right_icon != null
		right.custom_minimum_size = icon_size


func _update_label() -> void:
	var lbl := get_node_or_null("ContentContainer/Label") as RichTextLabel
	if lbl:
		lbl.text = button_text
		lbl.add_theme_font_override("normal_font", label_font)
		lbl.add_theme_font_size_override("normal_font_size", label_font_size)
		lbl.add_theme_font_size_override("bold_font_size", label_font_size)
		lbl.add_theme_font_size_override("italics_font_size", label_font_size)
		lbl.add_theme_color_override("default_color", text_color)


func _update_nine_patches() -> void:
	for node_name in ["Background", "BackgroundPressed", "Shadow"]:
		var node := get_node_or_null(node_name) as NinePatchRect
		if not node:
			continue
		node.patch_margin_left = patch_margin
		node.patch_margin_right = patch_margin
		node.patch_margin_top = patch_margin
		node.patch_margin_bottom = patch_margin

	var bg := get_node_or_null("Background") as NinePatchRect
	if bg and normal_texture:
		bg.texture = normal_texture

	var bg_pressed := get_node_or_null("BackgroundPressed") as NinePatchRect
	if bg_pressed and pressed_texture:
		bg_pressed.texture = pressed_texture

	var shadow := get_node_or_null("Shadow") as NinePatchRect
	if shadow and normal_texture:
		shadow.texture = normal_texture


func _update_visuals() -> void:
	modulate.a = 0.33 if disabled else 1.0


func _on_button_down() -> void:
	if Engine.is_editor_hint():
		return

	var bg := get_node_or_null("Background") as NinePatchRect
	var bg_pressed := get_node_or_null("BackgroundPressed") as NinePatchRect
	if bg:
		bg.visible = false
	if bg_pressed:
		bg_pressed.visible = true

	var content := get_node_or_null("ContentContainer") as Control
	if content:
		container_height = content.position.y
		content.position.y += size.y / 16.0


func _on_button_up() -> void:
	if Engine.is_editor_hint():
		return

	var bg := get_node_or_null("Background") as NinePatchRect
	var bg_pressed := get_node_or_null("BackgroundPressed") as NinePatchRect
	if bg:
		bg.visible = true
	if bg_pressed:
		bg_pressed.visible = false

	var content := get_node_or_null("ContentContainer") as Control
	if content:
		content.position.y = container_height
