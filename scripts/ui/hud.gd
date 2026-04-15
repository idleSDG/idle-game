extends CanvasLayer

@onready var level_label: Label = $HUD/LevelLabel
@onready var xp_bar: ProgressBar = $HUD/XPBar
@onready var xp_label: Label = $HUD/XPLabel
@onready var test_button: Button = $HUD/TestButton

@onready var ingredient_hud: Dictionary = {
	Ingredient.Type.KINETIC_SHARD: {
		"counter": %KineticShardsCounterLabel,
		"gain_rate": %KineticShardsGainRateLabel,
		"progress_bar": %KineticShardsProgressBar,
		"momentum_label_today": %KineticShardsMomentumTodayLabel,
		"momentum_label_tomorrow": %KineticShardsMomentumTomorrowLabel,
		"momentum_graph_line": %KineticShardsMomentumGraphLine
	},
		Ingredient.Type.FOCUS_FLUX: {
		"counter": %FocusFluxCounterLabel,
		"gain_rate": %FocusFluxGainRateLabel,
		"progress_bar": %FocusFluxProgressBar,
		"momentum_label": %FocusFluxMomentum,
		"momentum_graph_line": %FocusFluxMomentumGraphLine
	}
}

func _ready() -> void:
	# Connect to PlayerProgress signals
	PlayerProgress.xp_changed.connect(_on_xp_changed)
	PlayerProgress.leveled_up.connect(_on_leveled_up)
	# Connect to Ingredient signals
	PlayerInventory.ingredients_changed.connect(_on_ingredients_changed)
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
	
func _on_ingredients_changed(ingredients: Dictionary[Ingredient.Type, Ingredient]) -> void:
	for type in ingredients:
		if type == Ingredient.Type.KINETIC_SHARD:
			var ingredient = ingredients[type]
			var yesterday_steps : int = StepsProgress.get_steps_for_day_offset(1)
			var todays_steps : int = StepsProgress.get_steps_for_day_offset(0)
			var today_momentum_pct = ingredient.momentum_tracker.momentumConfig.get_multiplier(float(yesterday_steps)) * 100.0
			var tomorrow_momentum_pct = ingredient.momentum_tracker.momentumConfig.get_multiplier(float(todays_steps)) * 100.0
			ingredient_hud[type].counter.text = "%d / %d" % [ingredient.count, ingredient.capacity]
			ingredient_hud[type].gain_rate.text = "%.02f / min" % (ingredient.get_current_gain_rate() * 60)
			ingredient_hud[type].momentum_label_today.text = "today's momentum:\n%d steps (%.02f %%)" % [yesterday_steps, today_momentum_pct]
			ingredient_hud[type].momentum_label_tomorrow.text = "tomorrow's momentum:\n%d steps (%.02f %%)" % [todays_steps, tomorrow_momentum_pct]
			ingredient_hud[type].momentum_graph_line.draw_graph(StepsProgress.get_last_days_steps_history(8))
			if ingredient.count < ingredient.capacity:
				ingredient_hud[type].progress_bar.value = ingredient.get_progress_percentage()
			else:
				ingredient_hud[type].progress_bar.value = 100.0
		elif type == Ingredient.Type.FOCUS_FLUX:
			var ingredient = ingredients[type]
			var screen_time : int = ScreenTimeProgress.get_latest_value_for_profile().get("val", 0)
			var screen_momentum_pct : int = ingredient.momentum_tracker.momentumConfig.get_multiplier(float(screen_time)) * 100.0
			ingredient_hud[type].counter.text = "%d / %d" % [ingredient.count, ingredient.capacity]
			ingredient_hud[type].gain_rate.text = "%.02f / min" % (ingredient.get_current_gain_rate() * 60)
			ingredient_hud[type].momentum_label.text = "current momentum:\n%d minutes (%.02f %%)\n\n" % [-screen_time, screen_momentum_pct]
			ingredient_hud[type].momentum_graph_line.draw_graph(ScreenTimeProgress.get_last_days_steps_history(1))
			if ingredient.count < ingredient.capacity:
				ingredient_hud[type].progress_bar.value = ingredient.get_progress_percentage()
			else:
				ingredient_hud[type].progress_bar.value = 100.0
func _on_kinetic_shards_spend_button_pressed() -> void:
	if PlayerInventory.ingredients[Ingredient.Type.KINETIC_SHARD].count > 0:
		PlayerInventory.ingredients[Ingredient.Type.KINETIC_SHARD].count -= 1


func _on_focus_flux_spend_button_pressed() -> void:
	if PlayerInventory.ingredients[Ingredient.Type.FOCUS_FLUX].count > 0:
		PlayerInventory.ingredients[Ingredient.Type.FOCUS_FLUX].count -= 1
