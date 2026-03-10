extends CanvasLayer

@onready var level_label: Label = $VBoxContainer/LevelLabel
@onready var xp_bar: ProgressBar = $VBoxContainer/XPBar
@onready var xp_label: Label = $VBoxContainer/XPLabel
@onready var test_button: Button = $VBoxContainer/TestButton

func _ready() -> void:
	# Connect to PlayerProgress signals
	PlayerProgress.xp_changed.connect(_on_xp_changed)
	PlayerProgress.leveled_up.connect(_on_leveled_up)
	# Set test button text
	test_button.text = "Add +50 XP"
	# Draw initial state
	_refresh_ui()

func _refresh_ui() -> void:
	level_label.text = "Level %d" % PlayerProgress.level
	xp_bar.value = PlayerProgress.xp_progress_ratio() * 100.0
	xp_label.text = "%d / %d XP" % [PlayerProgress.current_xp, PlayerProgress.xp_required_for_next_level()]

func _on_xp_changed(current_xp: int, xp_required: int) -> void:
	xp_bar.value = PlayerProgress.xp_progress_ratio() * 100.0
	xp_label.text = "%d / %d XP" % [current_xp, xp_required]

func _on_leveled_up(new_level: int) -> void:
	level_label.text = "Level %d" % new_level

func _on_test_button_pressed() -> void:
	PlayerProgress.add_xp(50)
