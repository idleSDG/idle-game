extends Line2D

@export var padding: float = 20.0

var _example_dataset = [
	{"time": 0, "val": 10},
	{"time": 20, "val": 50},
	{"time": 25, "val": 20},
	{"time": 100, "val": 90}
]
var _current_dataset: Array = []

func _ready():
	_current_dataset = _example_dataset.duplicate(true)
	get_parent().resized.connect(func(): draw_graph(_current_dataset))
	draw_graph(_current_dataset)

func draw_graph(dataset):
	clear_points()
	if dataset.size() < 2: return
	_current_dataset = dataset.duplicate(true)

	var parent_size = get_parent().size
	var draw_width = parent_size.x - (padding * 2)
	var draw_height = parent_size.y - (padding * 2)

	# Sort the data for representation
	var sorted_dataset = dataset.duplicate(true)
	sorted_dataset.sort_custom(func(a, b): return float(a["time"]) < float(b["time"]))

	# 1. Find Ranges
	var times = sorted_dataset.map(func(d): return d.time)
	var values = sorted_dataset.map(func(d): return d.val)
	
	var min_t = times.min()
	var max_t = times.max()
	var min_v = values.min()
	var max_v = values.max()

	# Prevent division by zero if all values or times are the same
	var t_range = max(max_t - min_t, 1.0)
	var v_range = max(max_v - min_v, 1.0)

	# 2. Map and Draw
	for data in sorted_dataset:
		# Calculate X based on timestamp progress (0.0 to 1.0)
		var t_ratio = (float)(data.time - min_t) / t_range
		var x = padding + (t_ratio * draw_width)
		
		# Calculate Y based on value progress (0.0 to 1.0)
		var v_ratio = (float)(data.val - min_v) / v_range
		var y = (parent_size.y - padding) - (v_ratio * draw_height)
		
		add_point(Vector2(x, y))
