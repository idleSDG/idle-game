@tool
class_name GraphDecorations extends Control

var _plot_padding_left: float = 20.0
var _plot_padding_top: float = 20.0
var _plot_padding_right: float = 20.0
var _plot_padding_bottom: float = 20.0
var _gridlines_enabled: bool = false
var _x_gridline_spacing: float = 14400.0
var _y_gridline_spacing: float = 10.0
var _gridline_color: Color = Color(0.0, 0.0, 0.0, 0.15)
var _gridline_width: float = 1.0
var _graph_background_stylebox: StyleBox
var _y_axis_marker_values: PackedInt32Array = PackedInt32Array()
var _y_axis_marker_suffix: String = "%"
var _x_axis_markers_visible: bool = false
var _x_axis_marker_interval_hours: int = 4
var _axis_marker_label_settings: LabelSettings
var _y_axis_marker_padding_left: float = 8.0
var _y_axis_marker_padding_right: float = 2.0
var _x_axis_marker_padding_top: float = 2.0
var _x_axis_marker_padding_bottom: float = 8.0
var _baseline_values: PackedFloat32Array = PackedFloat32Array()
var _baseline_color: Color = Color(0.8, 0.2, 0.2, 0.8)
var _baseline_area_styleboxes: Array[StyleBox] = []
var _min_time: float = 0.0
var _max_time: float = 1.0
var _min_value: float = 0.0
var _max_value: float = 1.0
var _has_value_range: bool = false


func configure_grid(
	is_enabled: bool,
	x_spacing: float,
	y_spacing: float,
	color: Color,
	width: float,
	background_stylebox: StyleBox
) -> void:
	_gridlines_enabled = is_enabled
	_x_gridline_spacing = x_spacing
	_y_gridline_spacing = y_spacing
	_gridline_color = color
	_gridline_width = width
	_graph_background_stylebox = background_stylebox
	queue_redraw()


func configure_axis_markers(
	y_values: PackedInt32Array,
	y_suffix: String,
	x_visible: bool,
	x_interval_hours: int,
	label_settings: LabelSettings,
	y_padding_left: float,
	y_padding_right: float,
	x_padding_top: float,
	x_padding_bottom: float
) -> void:
	_y_axis_marker_values = y_values
	_y_axis_marker_suffix = y_suffix
	_x_axis_markers_visible = x_visible
	_x_axis_marker_interval_hours = x_interval_hours
	_axis_marker_label_settings = label_settings
	_y_axis_marker_padding_left = y_padding_left
	_y_axis_marker_padding_right = y_padding_right
	_x_axis_marker_padding_top = x_padding_top
	_x_axis_marker_padding_bottom = x_padding_bottom
	queue_redraw()


func configure_baselines(
	values: PackedFloat32Array,
	color: Color,
	area_styleboxes: Array[StyleBox]
) -> void:
	_baseline_values = values
	_baseline_color = color
	_baseline_area_styleboxes = area_styleboxes
	queue_redraw()


func set_plot_state(
	plot_padding_left: float,
	plot_padding_top: float,
	plot_padding_right: float,
	plot_padding_bottom: float,
	min_time: float,
	max_time: float,
	min_value: float,
	max_value: float,
	has_value_range: bool
) -> void:
	_plot_padding_left = plot_padding_left
	_plot_padding_top = plot_padding_top
	_plot_padding_right = plot_padding_right
	_plot_padding_bottom = plot_padding_bottom
	_min_time = min_time
	_max_time = max_time
	_min_value = min_value
	_max_value = max_value
	_has_value_range = has_value_range
	queue_redraw()


func _draw() -> void:
	var plot_left: float = _plot_padding_left
	var plot_right: float = maxf(size.x - _plot_padding_right, plot_left)
	var plot_top: float = _plot_padding_top
	var plot_bottom: float = maxf(size.y - _plot_padding_bottom, plot_top)

	if _graph_background_stylebox != null:
		draw_style_box(
			_graph_background_stylebox,
			Rect2(plot_left, plot_top, plot_right - plot_left, plot_bottom - plot_top)
		)
	if _has_value_range:
		_draw_baseline_areas(plot_left, plot_right, plot_top, plot_bottom)
	if _gridlines_enabled:
		_draw_gridlines(plot_left, plot_right, plot_top, plot_bottom)
	if _has_value_range:
		_draw_baselines(plot_left, plot_right, plot_top, plot_bottom)
		_draw_axis_markers(plot_left, plot_right, plot_top, plot_bottom)


func _draw_gridlines(
	plot_left: float,
	plot_right: float,
	plot_top: float,
	plot_bottom: float
) -> void:
	var half_width: float = _gridline_width * 0.5
	var horizontal_start: Vector2 = Vector2(plot_left - half_width, 0.0)
	var horizontal_end: Vector2 = Vector2(plot_right + half_width, 0.0)
	var vertical_start: Vector2 = Vector2(0.0, plot_top - half_width)
	var vertical_end: Vector2 = Vector2(0.0, plot_bottom + half_width)

	var first_time: float = ceilf(_min_time / _x_gridline_spacing) * _x_gridline_spacing
	var grid_time: float = first_time
	while grid_time <= _max_time:
		var x: float = _time_to_x(grid_time, plot_left, plot_right)
		draw_line(
			Vector2(x, vertical_start.y),
			Vector2(x, vertical_end.y),
			_gridline_color,
			_gridline_width
		)
		grid_time += _x_gridline_spacing
	if not is_equal_approx(_time_to_x(first_time, plot_left, plot_right), plot_left):
		draw_line(
			Vector2(plot_left, vertical_start.y),
			Vector2(plot_left, vertical_end.y),
			_gridline_color,
			_gridline_width
		)
	if not is_equal_approx(_time_to_x(grid_time - _x_gridline_spacing, plot_left, plot_right), plot_right):
		draw_line(
			Vector2(plot_right, vertical_start.y),
			Vector2(plot_right, vertical_end.y),
			_gridline_color,
			_gridline_width
		)

	var value_range: float = maxf(_max_value - _min_value, 1.0)
	var plot_height: float = maxf(plot_bottom - plot_top, 1.0)
	var minimum_gridline_gap: float = 24.0
	var configured_gridline_count: float = value_range / _y_gridline_spacing
	var maximum_gridline_count: float = maxf(floorf(plot_height / minimum_gridline_gap), 1.0)
	var spacing_multiplier: float = maxf(ceilf(configured_gridline_count / maximum_gridline_count), 1.0)
	var effective_y_spacing: float = _y_gridline_spacing * spacing_multiplier
	var first_value: float = ceilf(_min_value / effective_y_spacing) * effective_y_spacing
	var grid_value: float = first_value
	while grid_value <= _max_value:
		var y: float = _value_to_y(grid_value, plot_top, plot_bottom)
		draw_line(
			Vector2(horizontal_start.x, y),
			Vector2(horizontal_end.x, y),
			_gridline_color,
			_gridline_width
		)
		grid_value += effective_y_spacing
	if not is_equal_approx(_value_to_y(first_value, plot_top, plot_bottom), plot_bottom):
		draw_line(
			Vector2(horizontal_start.x, plot_bottom),
			Vector2(horizontal_end.x, plot_bottom),
			_gridline_color,
			_gridline_width
		)
	if not is_equal_approx(_value_to_y(grid_value - effective_y_spacing, plot_top, plot_bottom), plot_top):
		draw_line(
			Vector2(horizontal_start.x, plot_top),
			Vector2(horizontal_end.x, plot_top),
			_gridline_color,
			_gridline_width
		)


func _draw_baselines(
	plot_left: float,
	plot_right: float,
	plot_top: float,
	plot_bottom: float
) -> void:
	var value_range: float = maxf(_max_value - _min_value, 1.0)
	var plot_height: float = plot_bottom - plot_top
	for baseline_value: float in _baseline_values:
		var value_ratio: float = (baseline_value - _min_value) / value_range
		var y: float = plot_bottom - (value_ratio * plot_height)
		draw_dashed_line(
			Vector2(plot_left, y),
			Vector2(plot_right, y),
			_baseline_color,
			1.0,
			6.0,
			true
		)


func _draw_baseline_areas(
	plot_left: float,
	plot_right: float,
	plot_top: float,
	plot_bottom: float
) -> void:
	var sorted_values: Array[float] = []
	for baseline_value: float in _baseline_values:
		sorted_values.append(baseline_value)
	sorted_values.sort()

	var area_count: int = mini(sorted_values.size() - 1, _baseline_area_styleboxes.size())
	for index: int in range(area_count):
		var stylebox: StyleBox = _baseline_area_styleboxes[index]
		if stylebox == null:
			continue
		var top_y: float = _value_to_y(sorted_values[index + 1], plot_top, plot_bottom)
		var bottom_y: float = _value_to_y(sorted_values[index], plot_top, plot_bottom)
		draw_style_box(stylebox, Rect2(plot_left, top_y, plot_right - plot_left, bottom_y - top_y))


func _draw_axis_markers(
	plot_left: float,
	plot_right: float,
	plot_top: float,
	plot_bottom: float
) -> void:
	var font: Font = get_theme_default_font()
	var font_size: int = get_theme_default_font_size()
	var font_color: Color = get_theme_color("font_color", "Label")
	if _axis_marker_label_settings != null:
		if _axis_marker_label_settings.font != null:
			font = _axis_marker_label_settings.font
		font_size = _axis_marker_label_settings.font_size
		font_color = _axis_marker_label_settings.font_color
	else:
		font_color = get_theme_color("font_color", "Label")

	for marker_value: int in _y_axis_marker_values:
		if float(marker_value) < _min_value or float(marker_value) > _max_value:
			continue
		var marker_text: String = "%d%s" % [marker_value, _y_axis_marker_suffix]
		var y: float = _value_to_y(float(marker_value), plot_top, plot_bottom)
		var marker_left: float = _y_axis_marker_padding_left
		var marker_right: float = plot_left - _y_axis_marker_padding_right
		draw_string(
			font,
			Vector2(marker_left, y + (font_size * 0.35)),
			marker_text,
			HORIZONTAL_ALIGNMENT_RIGHT,
			maxf(marker_right - marker_left, 0.0),
			font_size,
			font_color
		)

	if not _x_axis_markers_visible:
		return
	var interval_seconds: int = _x_axis_marker_interval_hours * 3600
	var first_marker: int = ceili(_min_time / float(interval_seconds)) * interval_seconds
	var marker_time: int = first_marker
	var previous_label_right: float = -INF
	var label_gap: float = 8.0
	while marker_time <= int(_max_time):
		var time_ratio: float = (float(marker_time) - _min_time) / maxf(_max_time - _min_time, 1.0)
		var x: float = plot_left + (time_ratio * (plot_right - plot_left))
		var datetime: Dictionary = Time.get_datetime_dict_from_unix_time(marker_time)
		var marker_text: String = _format_x_axis_marker(datetime, interval_seconds)
		var text_width: float = font.get_string_size(
			marker_text,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1.0,
			font_size
		).x
		var label_left: float = x - (text_width * 0.5)
		var label_right: float = x + (text_width * 0.5)
		if label_left >= previous_label_right + label_gap:
			draw_string(
				font,
				Vector2(
					label_left,
					plot_bottom + _x_axis_marker_padding_top + font_size
				),
				marker_text,
				HORIZONTAL_ALIGNMENT_LEFT,
				-1.0,
				font_size,
				font_color
			)
			previous_label_right = label_right
		marker_time += interval_seconds


func _format_x_axis_marker(datetime: Dictionary, interval_seconds: int) -> String:
	if interval_seconds >= 86400:
		return "%02d-%02d" % [datetime["month"], datetime["day"]]
	return "%02d:%02d" % [datetime["hour"], datetime["minute"]]


func _value_to_y(value: float, plot_top: float, plot_bottom: float) -> float:
	var value_ratio: float = (value - _min_value) / maxf(_max_value - _min_value, 1.0)
	return plot_bottom - (value_ratio * (plot_bottom - plot_top))


func _time_to_x(time: float, plot_left: float, plot_right: float) -> float:
	var time_ratio: float = (time - _min_time) / maxf(_max_time - _min_time, 1.0)
	return plot_left + (time_ratio * (plot_right - plot_left))
