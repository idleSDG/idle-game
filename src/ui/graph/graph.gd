@tool
class_name Graph2D extends Control

@export_group("Layout")
@export_range(0.0, 256.0, 1.0) var padding: float = 20.0:
	set(value):
		padding = value
		_refresh_graph()
@export var panel_stylebox: StyleBox:
	set(value):
		panel_stylebox = value
		_watch_resource(value)
		_refresh_graph()
@export var graph_background_stylebox: StyleBox:
	set(value):
		graph_background_stylebox = value
		_watch_resource(value)
		_refresh_graph()

@export_group("Graph Line")
@export var graph_line_color: Color = Color.BLACK:
	set(value):
		graph_line_color = value
		_refresh_graph()
@export_range(0.0, 64.0, 0.5) var graph_line_width: float = 4.0:
	set(value):
		graph_line_width = value
		_refresh_graph()
@export var graph_line_antialiased: bool = true:
	set(value):
		graph_line_antialiased = value
		_refresh_graph()
@export var graph_line_smoothing: bool = false:
	set(value):
		graph_line_smoothing = value
		_refresh_graph()

@export_group("Gridlines")
@export var gridlines_enabled: bool = false:
	set(value):
		gridlines_enabled = value
		_refresh_graph()
@export_range(1.0, 604800.0, 1.0, "or_greater") var x_gridline_spacing: float = 14400.0:
	set(value):
		x_gridline_spacing = value
		_refresh_graph()
@export_range(1.0, 1000000.0, 1.0, "or_greater") var y_gridline_spacing: float = 10.0:
	set(value):
		y_gridline_spacing = value
		_refresh_graph()
@export var gridline_color: Color = Color(0.0, 0.0, 0.0, 0.15):
	set(value):
		gridline_color = value
		_refresh_graph()
@export_range(0.0, 32.0, 0.5) var gridline_width: float = 1.0:
	set(value):
		gridline_width = value
		_refresh_graph()

@export_group("Axis Titles")
@export var x_axis_title_visible: bool = false:
	set(value):
		x_axis_title_visible = value
		_refresh_graph()
@export var x_axis_title: String = "X Axis":
	set(value):
		x_axis_title = value
		_refresh_graph()
@export var y_axis_title_visible: bool = false:
	set(value):
		y_axis_title_visible = value
		_refresh_graph()
@export var y_axis_title: String = "Y Axis":
	set(value):
		y_axis_title = value
		_refresh_graph()
@export_range(0.0, 128.0, 1.0) var axis_title_gap: float = 4.0:
	set(value):
		axis_title_gap = value
		_refresh_graph()
@export var x_axis_label_settings: LabelSettings:
	set(value):
		x_axis_label_settings = value
		_watch_resource(value)
		_refresh_graph()
@export var y_axis_label_settings: LabelSettings:
	set(value):
		y_axis_label_settings = value
		_watch_resource(value)
		_refresh_graph()

@export_group("Axis Value Markers")
@export var y_axis_marker_values: PackedInt32Array = PackedInt32Array():
	set(value):
		y_axis_marker_values = value
		_refresh_graph()
@export var y_axis_marker_suffix: String = "%":
	set(value):
		y_axis_marker_suffix = value
		_refresh_graph()
@export var x_axis_markers_visible: bool = false:
	set(value):
		x_axis_markers_visible = value
		_refresh_graph()
@export_range(1, 24, 1) var x_axis_marker_interval_hours: int = 4:
	set(value):
		x_axis_marker_interval_hours = value
		_refresh_graph()
@export var axis_marker_label_settings: LabelSettings:
	set(value):
		axis_marker_label_settings = value
		_watch_resource(value)
		_refresh_graph()
@export_range(0.0, 64.0, 1.0) var y_axis_marker_padding_left: float = 8.0:
	set(value):
		y_axis_marker_padding_left = value
		_refresh_graph()
@export_range(0.0, 64.0, 1.0) var y_axis_marker_padding_right: float = 2.0:
	set(value):
		y_axis_marker_padding_right = value
		_refresh_graph()
@export_range(0.0, 64.0, 1.0) var x_axis_marker_padding_top: float = 2.0:
	set(value):
		x_axis_marker_padding_top = value
		_refresh_graph()
@export_range(0.0, 64.0, 1.0) var x_axis_marker_padding_bottom: float = 8.0:
	set(value):
		x_axis_marker_padding_bottom = value
		_refresh_graph()

@export_group("Baselines")
@export var baseline_values: PackedFloat32Array = PackedFloat32Array():
	set(value):
		baseline_values = value
		_refresh_graph()
@export var baseline_color: Color = Color(0.8, 0.2, 0.2, 0.8):
	set(value):
		baseline_color = value
		_refresh_graph()
@export var baseline_area_styleboxes: Array[StyleBox] = []:
	set(value):
		baseline_area_styleboxes = value
		for stylebox: StyleBox in value:
			_watch_resource(stylebox)
		_refresh_graph()

@onready var panel: Panel = $Panel
@onready var decorations: GraphDecorations = %Decorations
@onready var line: Line2D = %Line
@onready var x_axis_label: Label = %XAxisLabel
@onready var y_axis_label: Label = %YAxisLabel

var _plot_padding_left: float = 20.0
var _plot_padding_bottom: float = 20.0
var _example_dataset: Array[Dictionary] = [
	{"time": Time.get_unix_time_from_system()-60*60*5, "val": 10},
	{"time": Time.get_unix_time_from_system()-60*60*4, "val": 50},
	{"time": Time.get_unix_time_from_system()-60*60*3, "val": 20},
	{"time": Time.get_unix_time_from_system()-60*60*2, "val": 90},
	{"time": Time.get_unix_time_from_system()-60*60*1, "val": 120},
	{"time": Time.get_unix_time_from_system(), "val": 75},
]
var _current_dataset: Array[Dictionary] = []


func _ready() -> void:
	_current_dataset = _example_dataset.duplicate(true)
	panel.resized.connect(_refresh_graph)
	_watch_resource(panel_stylebox)
	_watch_resource(graph_background_stylebox)
	_watch_resource(x_axis_label_settings)
	_watch_resource(y_axis_label_settings)
	_watch_resource(axis_marker_label_settings)
	for stylebox: StyleBox in baseline_area_styleboxes:
		_watch_resource(stylebox)
	_refresh_graph()


func draw_graph(dataset: Array[Dictionary]) -> void:
	_current_dataset = dataset.duplicate(true)
	_refresh_graph()


func _refresh_graph() -> void:
	if not is_node_ready():
		return

	_configure_panel_and_labels()
	_configure_line()
	line.clear_points()
	if _current_dataset.size() < 2:
		_configure_decorations(0.0, 1.0, 0.0, 1.0, false)
		return

	var sorted_dataset: Array[Dictionary] = _current_dataset.duplicate(true)
	sorted_dataset.sort_custom(
		func(a: Dictionary, b: Dictionary) -> bool:
			return float(a["time"]) < float(b["time"])
	)

	var min_time: float = float(sorted_dataset[0]["time"])
	var max_time: float = min_time
	var min_value: float = float(sorted_dataset[0]["val"])
	var max_value: float = min_value
	for data: Dictionary in sorted_dataset:
		var time: float = float(data["time"])
		var value: float = float(data["val"])
		min_time = minf(min_time, time)
		max_time = maxf(max_time, time)
		min_value = minf(min_value, value)
		max_value = maxf(max_value, value)

	for baseline_value: float in baseline_values:
		min_value = minf(min_value, baseline_value)
		max_value = maxf(max_value, baseline_value)
	for marker_value: int in y_axis_marker_values:
		min_value = minf(min_value, float(marker_value))
		max_value = maxf(max_value, float(marker_value))

	var time_range: float = maxf(max_time - min_time, 1.0)
	var value_range: float = maxf(max_value - min_value, 1.0)
	var draw_width: float = maxf(panel.size.x - _plot_padding_left - padding, 0.0)
	var draw_height: float = maxf(panel.size.y - padding - _plot_padding_bottom, 0.0)

	for data: Dictionary in sorted_dataset:
		var time_ratio: float = (float(data["time"]) - min_time) / time_range
		var value_ratio: float = (float(data["val"]) - min_value) / value_range
		var x: float = _plot_padding_left + (time_ratio * draw_width)
		var y: float = (panel.size.y - _plot_padding_bottom) - (value_ratio * draw_height)
		line.add_point(Vector2(x, y))

	_configure_decorations(min_time, max_time, min_value, max_value, true)


func _configure_decorations(
	min_time: float,
	max_time: float,
	min_value: float,
	max_value: float,
	has_value_range: bool
) -> void:
	decorations.configure_grid(
		gridlines_enabled,
		x_gridline_spacing,
		y_gridline_spacing,
		gridline_color,
		gridline_width,
		graph_background_stylebox
	)
	decorations.configure_axis_markers(
		y_axis_marker_values,
		y_axis_marker_suffix,
		x_axis_markers_visible,
		x_axis_marker_interval_hours,
		axis_marker_label_settings,
		y_axis_marker_padding_left,
		y_axis_marker_padding_right,
		x_axis_marker_padding_top,
		x_axis_marker_padding_bottom
	)
	decorations.configure_baselines(
		baseline_values,
		baseline_color,
		baseline_area_styleboxes
	)
	decorations.set_plot_state(
		_plot_padding_left,
		padding,
		padding,
		_plot_padding_bottom,
		min_time,
		max_time,
		min_value,
		max_value,
		has_value_range
	)


func _configure_line() -> void:
	line.default_color = graph_line_color
	line.width = graph_line_width
	line.antialiased = graph_line_antialiased
	var joint_mode: Line2D.LineJointMode = Line2D.LINE_JOINT_ROUND if graph_line_smoothing else Line2D.LINE_JOINT_SHARP
	var cap_mode: Line2D.LineCapMode = Line2D.LINE_CAP_ROUND if graph_line_smoothing else Line2D.LINE_CAP_NONE
	line.joint_mode = joint_mode
	line.begin_cap_mode = cap_mode
	line.end_cap_mode = cap_mode


func _configure_panel_and_labels() -> void:
	if panel_stylebox != null:
		panel.add_theme_stylebox_override("panel", panel_stylebox)
	else:
		panel.remove_theme_stylebox_override("panel")

	x_axis_label.visible = x_axis_title_visible
	x_axis_label.text = x_axis_title
	x_axis_label.label_settings = x_axis_label_settings
	y_axis_label.visible = y_axis_title_visible
	y_axis_label.text = y_axis_title
	y_axis_label.label_settings = y_axis_label_settings

	_configure_plot_padding()

	var x_label_height: float = 0.0
	if x_axis_title_visible:
		x_label_height = x_axis_label.get_minimum_size().y
	var y_label_width: float = 0.0
	if y_axis_title_visible:
		y_label_width = y_axis_label.get_minimum_size().y
	var left_reserve: float = 0.0
	if y_axis_title_visible:
		left_reserve += y_label_width + axis_title_gap
	var bottom_reserve: float = 0.0
	if x_axis_title_visible:
		bottom_reserve += x_label_height + axis_title_gap
	panel.offset_left = padding + left_reserve
	#panel.offset_top = padding
	panel.offset_right = -padding
	panel.offset_bottom = -(padding + bottom_reserve)

	x_axis_label.position = Vector2(
		panel.position.x,
		panel.position.y + panel.size.y + axis_title_gap
	)
	x_axis_label.size = Vector2(panel.size.x, x_label_height)

	y_axis_label.position = Vector2(0.0, panel.position.y + panel.size.y)
	y_axis_label.size = Vector2(panel.size.y, y_label_width)


func _configure_plot_padding() -> void:
	var marker_font: Font = get_theme_default_font()
	var marker_font_size: int = get_theme_default_font_size()
	if axis_marker_label_settings != null:
		if axis_marker_label_settings.font != null:
			marker_font = axis_marker_label_settings.font
		marker_font_size = axis_marker_label_settings.font_size

	var y_marker_width: float = 0.0
	for marker_value: int in y_axis_marker_values:
		var marker_text: String = "%d%s" % [marker_value, y_axis_marker_suffix]
		y_marker_width = maxf(
			y_marker_width,
			marker_font.get_string_size(
				marker_text,
				HORIZONTAL_ALIGNMENT_LEFT,
				-1.0,
				marker_font_size
			).x
		)

	_plot_padding_left = 0.0
	if not y_axis_marker_values.is_empty():
		_plot_padding_left += y_axis_marker_padding_left + y_marker_width + y_axis_marker_padding_right
	_plot_padding_bottom = 0.0
	if x_axis_markers_visible:
		_plot_padding_bottom += (
			x_axis_marker_padding_top
			+ marker_font.get_height(marker_font_size)
			+ x_axis_marker_padding_bottom
		)


func _watch_resource(resource: Resource) -> void:
	if resource == null or resource.changed.is_connected(_refresh_graph):
		return
	resource.changed.connect(_refresh_graph)
