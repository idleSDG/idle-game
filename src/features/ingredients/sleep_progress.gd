class_name sleep_progress
extends Node

signal sleep_data_ready
signal sleep_permissions

var _plugin_name = "GodotStepAndSleepPlugin"
var _sleep_plugin
var _has_sleep_data: bool = false

# One deeper than 7 for lookback after midnight
var lookback_days: int = 8
## Dictionary is "YYYY-MM-DD" -> int.
var daily_sleep_by_date: Dictionary = { }
var has_history_permissions: bool
const GRAPH_MAX_SLEEP: int = 10 * 60


func _init() -> void:
	has_history_permissions = false
	if Engine.has_singleton(_plugin_name):
		_sleep_plugin = Engine.get_singleton(_plugin_name)
		_sleep_plugin.on_sleep_read.connect(_on_sleep)


func has_sleep_data() -> bool:
	return _has_sleep_data


func _mark_sleep_ready():
	if _has_sleep_data:
		return
	_has_sleep_data = true
	sleep_data_ready.emit()


func _on_sleep(dates: PackedStringArray, steps: PackedInt64Array):
	daily_sleep_by_date.clear()
	var count := mini(dates.size(), steps.size())
	for i in range(count):
		daily_sleep_by_date[dates[i]] = int(steps[i])

	_mark_sleep_ready()


func fetch_sleep():
	_sleep_plugin.read_daily_sleep(lookback_days)


func get_sleep_for_day_offset(offset: int) -> int:
	var key := _date_key_for_offset(offset)
	return int(daily_sleep_by_date.get(key, 0))


func get_momentum_sleep_for_day_offset(day_offset: int) -> float:
	return float(get_sleep_for_day_offset(day_offset))


func get_latest_value_for_profile() -> Dictionary:
	return {
		"time": Time.get_unix_time_from_system(),
		"val": get_momentum_sleep_for_day_offset(0),
	}


func get_profile_momentum_history_between(start_t: float, end_t: float) -> Array:
	var history: Array = []
	if end_t <= start_t:
		var day_offset_now := _day_offset_for_unix(end_t)
		history.append(
			{
				"time": end_t,
				"val": get_momentum_sleep_for_day_offset(day_offset_now),
			},
		)
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
		var day_momentum_sleep := get_momentum_sleep_for_day_offset(day_offset)

		history.append({ "time": cursor, "val": day_momentum_sleep })

		# Duplicate value at boundary so momentum doesn't get interpolated
		history.append({ "time": next_boundary, "val": day_momentum_sleep })
		cursor = next_boundary

	return history


func get_last_days_sleep_history(days: int = lookback_days) -> Array:
	var history: Array = []
	var sample_days: int = maxi(days, 1)
	var start_of_today := _start_of_day_unix(Time.get_unix_time_from_system())

	for offset in range(sample_days - 1, -1, -1):
		var clamped_steps := clampi(get_sleep_for_day_offset(offset), 0, GRAPH_MAX_SLEEP)
		var t := float(start_of_today - (offset * 86400))
		history.append(
			{
				"time": t,
				"val": float(clamped_steps),
			},
		)

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


func set_fallback_data():
	if not _has_sleep_data:
		daily_sleep_by_date.clear()
		daily_sleep_by_date[_date_key_for_offset(0)] = 6.5 * 60
		daily_sleep_by_date[_date_key_for_offset(1)] = 6 * 60
		daily_sleep_by_date[_date_key_for_offset(2)] = 7 * 60
		daily_sleep_by_date[_date_key_for_offset(3)] = 10 * 60
		daily_sleep_by_date[_date_key_for_offset(4)] = 8 * 60
		daily_sleep_by_date[_date_key_for_offset(5)] = 8 * 60
		daily_sleep_by_date[_date_key_for_offset(6)] = 4 * 60
		daily_sleep_by_date[_date_key_for_offset(7)] = 6 * 60
		_mark_sleep_ready()
