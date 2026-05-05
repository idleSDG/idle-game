extends Node

signal steps_data_ready
signal steps_permissions

var _plugin_name = "GodotStepPlugin"
var _steps_plugin
var _has_steps_data: bool = false

# 1 day today + 8 days needed for history
var lookback_days: int = 9
## Dictionary is "YYYY-MM-DD" -> int.
var daily_steps_by_date: Dictionary = {}
var has_history_permissions: bool
const GRAPH_MAX_STEPS: int = 12000

func _ready():
	has_history_permissions = false
	if Engine.has_singleton(_plugin_name):
		_steps_plugin = Engine.get_singleton(_plugin_name)
		_steps_plugin.on_steps_read.connect(_on_steps)
		_steps_plugin.on_steps_error.connect(_on_error)
		_steps_plugin.on_history_permission_result.connect(_on_history_permission)
		request_history_permissions()
	else:
		#fallback for testing
		_set_fallback_data()
		_mark_steps_ready()
		
func request_history_permissions():
	if Engine.has_singleton(_plugin_name):
		_steps_plugin.request_history_permissions()

func has_steps_data() -> bool:
	return _has_steps_data

func _mark_steps_ready():
	if _has_steps_data:
		return
	_has_steps_data = true
	steps_data_ready.emit()

func _on_steps(dates: PackedStringArray, steps: PackedInt64Array):
	daily_steps_by_date.clear()
	var count := mini(dates.size(), steps.size())
	for i in range(count):
		daily_steps_by_date[dates[i]] = int(steps[i])

	_mark_steps_ready()

func _on_error(err):
	print("Steps error:",err)
	_set_fallback_data()
	_mark_steps_ready()

func _on_history_permission(result : bool):
	if result:
		has_history_permissions = true
		emit_signal("steps_permissions")
		_fetch_steps()
		var timer = Timer.new()
		timer.wait_time = 10
		timer.autostart = true
		timer.one_shot = false
		timer.timeout.connect(_fetch_steps)
		add_child(timer)
	else:
		# For now set the steps to the fallback if permissions are denied
		_set_fallback_data()
		_mark_steps_ready()
	
func _fetch_steps():
	_steps_plugin.read_daily_steps(lookback_days)
	
func get_steps_for_day_offset(offset: int) -> int:
	var key := _date_key_for_offset(offset)
	return int(daily_steps_by_date.get(key, 0))

func get_momentum_steps_for_day_offset(day_offset: int) -> float:
	# Momentum for a day is set by the previous day's steps.
	return float(get_steps_for_day_offset(day_offset + 1))

func get_latest_value_for_profile() -> Dictionary:
	return {
		"time": Time.get_unix_time_from_system(),
		"val": get_momentum_steps_for_day_offset(0)
	}

func get_profile_momentum_history_between(start_t: float, end_t: float) -> Array:
	var history: Array = []
	if end_t <= start_t:
		var day_offset_now := _day_offset_for_unix(end_t)
		history.append({
			"time": end_t,
			"val": get_momentum_steps_for_day_offset(day_offset_now)
		})
		return history

	# Keep history window bounded by available lookback data.
	var max_window_seconds := float(lookback_days - 1) * 86400.0
	var clamped_start_t = max(start_t, end_t - max_window_seconds)

	var cursor = clamped_start_t
	while cursor < end_t:
		var day_start := float(_start_of_day_unix(cursor))
		var next_boundary = min(day_start + 86400.0, end_t)

		# Momentum used during a day comes from previous day's steps.
		var day_offset := _day_offset_for_unix(cursor)
		var day_momentum_steps := get_momentum_steps_for_day_offset(day_offset)

		history.append({"time": cursor, "val": day_momentum_steps})
		
		# Duplicate value at boundary so momentum doesn't get interpolated
		history.append({"time": next_boundary, "val": day_momentum_steps})
		cursor = next_boundary

	return history

func get_last_days_steps_history(days: int = lookback_days) -> Array:
	var history: Array = []
	var sample_days: int = maxi(days, 1)
	var start_of_today := _start_of_day_unix(Time.get_unix_time_from_system())

	for offset in range(sample_days - 1, -1, -1):
		var clamped_steps := clampi(get_steps_for_day_offset(offset), 0, GRAPH_MAX_STEPS)
		var t := float(start_of_today - (offset * 86400))
		history.append({
			"time": t,
			"val": float(clamped_steps)
		})

	return history

func _date_key_for_offset(offset: int) -> String:
	var start_of_today := _start_of_day_unix(Time.get_unix_time_from_system())
	var target_unix := start_of_today - (offset * 86400)

	# Build date key using local-adjusted unix
	var local_unix := int(target_unix) - _timezone_offset_seconds()
	var dt := Time.get_datetime_dict_from_unix_time(local_unix)
	return "%04d-%02d-%02d" % [dt["year"], dt["month"], dt["day"]]

func _timezone_offset_seconds() -> int:
	return -int(Time.get_time_zone_from_system()["bias"]) * 60

func _start_of_day_unix(unix_time: float) -> int:
	var offset := _timezone_offset_seconds()
	var local_unix := int(unix_time) - offset
	var local_day_start := local_unix - posmod(local_unix, 86400)
	return local_day_start + offset

func _day_offset_for_unix(unix_time: float) -> int:
	var start_of_today := _start_of_day_unix(Time.get_unix_time_from_system())
	var target_day_start := _start_of_day_unix(unix_time)
	var delta := start_of_today - target_day_start
	return maxi(int(floor(float(delta) / 86400.0)), 0)

func _set_fallback_data():
	daily_steps_by_date.clear()
	daily_steps_by_date[_date_key_for_offset(0)] = 5000
	daily_steps_by_date[_date_key_for_offset(1)] = 6000
	daily_steps_by_date[_date_key_for_offset(2)] = 1000
	daily_steps_by_date[_date_key_for_offset(3)] = 1000
	daily_steps_by_date[_date_key_for_offset(4)] = 1000
	daily_steps_by_date[_date_key_for_offset(5)] = 2000
	daily_steps_by_date[_date_key_for_offset(6)] = 1000
	daily_steps_by_date[_date_key_for_offset(7)] = 1000
	daily_steps_by_date[_date_key_for_offset(8)] = 1000
