class_name IngredientPopup extends Control

const INGREDIENT_PRESENTATION: Dictionary = {
	Ingredient.Type.KINETIC_SHARD: {
		"header": "Kinetic Shards",
		"description": "Gain [b][i]Kinetic Shards[/i][/b] by reaching your daily step target! (Current target: [b]6000 steps[/b])",
		"momentum_caption": "Today's Momentum:",
		"icon": preload("res://assets/icons/ingredients/ingredient_kinetic_shard.tres"),
		"progress_texture": preload("res://assets/hud/circle_bars/32x32 circle bar progress dark brown.png"),
		"history_duration_seconds": 7.0 * 24.0 * 60.0 * 60.0,
		"x_axis_marker_interval_hours": 24,
		"x_gridline_spacing_seconds": 24.0 * 60.0 * 60.0,
		"graph_value_scale": 1.0,
		"y_axis_title": "Steps",
		"y_axis_marker_values": [0, 6000, 12000],
		"y_gridline_spacing": 2000.0,
		"baseline_values": [6000.0],
	},
	Ingredient.Type.FOCUS_FLUX: {
		"header": "Focus Flux",
		"description": "Gain [b][i]Focus Flux[/i][/b] by limiting recent screen usage! (Current target: [b]20 minutes/h[/b])",
		"momentum_caption": "Current Momentum:",
		"icon": preload("res://assets/icons/ingredients/ingredient_focus_flux.tres"),
		"progress_texture": preload("res://assets/hud/circle_bars/32x32 circle bar progress blue.png"),
		"history_duration_seconds": 24.0 * 60.0 * 60.0,
		"x_axis_marker_interval_hours": 4,
		"x_gridline_spacing_seconds": 4.0 * 60.0 * 60.0,
		"graph_value_scale": -1.0,
		"y_axis_title": "Screen Time (min)",
		"y_axis_marker_values": [0, 20, 60],
		"y_gridline_spacing": 10.0,
		"baseline_values": [20.0],
	},
	Ingredient.Type.DREAM_SHARDS: {
		"header": "Dream Shards",
		"description": "Gain [b][i]Dream Shards[/i][/b] by registering a full night's sleep! (Current target: [b]7.5 hours[/b])",
		"momentum_caption": "Current Momentum:",
		"icon": preload("res://assets/icons/ingredients/ingredient_dream_shard.tres"),
		"progress_texture": preload("res://assets/hud/circle_bars/32x32 circle bar progress red orange.png"),
		"history_duration_seconds": 7.0 * 24.0 * 60.0 * 60.0,
		"x_axis_marker_interval_hours": 24,
		"x_gridline_spacing_seconds": 24.0 * 60.0 * 60.0,
		"graph_value_scale": 1.0 / 60.0,
		"y_axis_title": "Sleep (hours)",
		"y_axis_marker_values": [0, 6, 9],
		"y_gridline_spacing": 1.0,
		"baseline_values": [7.5],
	},
}

@export var ingredient_type: Ingredient.Type = Ingredient.Type.KINETIC_SHARD:
	set(value):
		ingredient_type = value
		if is_node_ready():
			_refresh_ui()

@onready var _header_label: Label = %IngredientHeaderLabel
@onready var _description_label: RichTextLabel = %IngredientDescriptionLabel
@onready var _progress_bar: TextureProgressBar = %IngredientProgressBar
@onready var _ingredient_icon: TextureRect = %IngredientIcon
@onready var _ingredient_count: Label = %IngredientCount
@onready var _momentum_caption: RichTextLabel = %MomentumRichTextLabel
@onready var _momentum_label: Label = %MomentumLabel
@onready var _ingredient_graph: Graph2D = %IngredientGraph2D


func _ready() -> void:
	visible = false
	PlayerInventory.ingredients_changed.connect(_on_ingredients_changed)
	_refresh_ui()


func open_popup() -> void:
	visible = true
	_refresh_ui()


func open_for_ingredient(type: Ingredient.Type) -> void:
	ingredient_type = type
	open_popup()


func _on_close_button_pressed() -> void:
	self.visible = false


func _on_background_clicked(input_event: InputEvent) -> void:
	if input_event is InputEventMouseButton:
		visible = false


func _on_ingredients_changed(ingredients: Dictionary[Ingredient.Type, Ingredient]) -> void:
	if visible and ingredients.has(ingredient_type):
		_refresh_ingredient_state(ingredients[ingredient_type])


func _refresh_ui() -> void:
	_refresh_presentation()
	if PlayerInventory.ingredients.has(ingredient_type):
		_refresh_ingredient_state(PlayerInventory.ingredients[ingredient_type])


func _refresh_presentation() -> void:
	var presentation: Dictionary = _get_presentation()
	_header_label.text = str(presentation.get("header", "Ingredient"))
	_description_label.text = str(presentation.get("description", ""))
	_momentum_caption.text = str(presentation.get("momentum_caption", "Current Momentum:"))
	_ingredient_icon.texture = presentation.get("icon") as Texture2D
	_progress_bar.texture_progress = presentation.get("progress_texture") as Texture2D
	_ingredient_graph.x_axis_title = "Time"
	_ingredient_graph.y_axis_title = str(presentation.get("y_axis_title", "Value"))
	_ingredient_graph.y_axis_marker_suffix = ""
	_ingredient_graph.y_axis_marker_values = PackedInt32Array(
		presentation.get("y_axis_marker_values", [])
	)
	_ingredient_graph.y_gridline_spacing = float(presentation.get("y_gridline_spacing", 10.0))
	_ingredient_graph.baseline_values = PackedFloat32Array(
		presentation.get("baseline_values", [])
	)
	_ingredient_graph.x_axis_marker_interval_hours = int(
		presentation.get("x_axis_marker_interval_hours", 4)
	)
	_ingredient_graph.x_gridline_spacing = float(
		presentation.get("x_gridline_spacing_seconds", 4.0 * 60.0 * 60.0)
	)


func _refresh_ingredient_state(ingredient: Ingredient) -> void:
	var momentum_percentage: float = ingredient.get_current_momentum_percentage()
	_ingredient_count.text = "%d / %d" % [ingredient.count, ingredient.capacity]
	_progress_bar.value = 100.0 if ingredient.count >= ingredient.capacity else ingredient.get_progress_percentage()
	_momentum_label.text = "%.02f%%" % momentum_percentage
	_ingredient_graph.draw_graph(_get_graph_history(ingredient))


func _get_graph_history(ingredient: Ingredient) -> Array[Dictionary]:
	var end_time: float = Time.get_unix_time_from_system()
	var start_time: float = end_time - _get_history_duration_seconds()
	var source_history: Array = ingredient.momentum_tracker.datasource.get_history(start_time, end_time)
	var value_scale: float = float(_get_presentation().get("graph_value_scale", 1.0))
	var graph_history: Array[Dictionary] = []

	for source_point: Dictionary in source_history:
		graph_history.append({
			"time": float(source_point.get("time", end_time)),
			"val": float(source_point.get("val", 0.0)) * value_scale,
		})

	return graph_history


func _get_history_duration_seconds() -> float:
	return float(_get_presentation().get("history_duration_seconds", 24.0 * 60.0 * 60.0))


func _get_presentation() -> Dictionary:
	return INGREDIENT_PRESENTATION.get(ingredient_type, {})
