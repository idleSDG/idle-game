extends Control

@onready var ingredient_hud: Dictionary = {
	Ingredient.Type.KINETIC_SHARD: {
		"counter": %KineticShardsCounterLabel,
		"gain_rate": %KineticShardsGainRateLabel,
		"momentum_label_today": %KineticShardsMomentumTodayLabel,
		"momentum_label_tomorrow": %KineticShardsMomentumTomorrowLabel,
		"momentum_graph_line": %KineticShardsMomentumGraphLine,
		"graph_percentage": %KineticShardsGraphPercentageLabel
	},
	Ingredient.Type.FOCUS_FLUX: {
		"counter": %FocusFluxCounterLabel,
		"gain_rate": %FocusFluxGainRateLabel,
		"momentum_label": %FocusFluxMomentum,
		"momentum_graph_line": %FocusFluxMomentumGraphLine,
		"graph_percentage": %FocusFluxGraphPercentageLabel
	},
	Ingredient.Type.DREAM_SHARDS: {
		"counter": %DreamShardsCounterLabel,
		"gain_rate": %DreamShardsGainRateLabel,
		"momentum_label": %DreamShardsMomentum,
		"momentum_graph_line": %DreamShardsMomentumGraphLine,
		"graph_percentage": %DreamShardsGraphPercentageLabel
	},
}

func _ready() -> void:
	self.visible = false
	PlayerInventory.ingredients_changed.connect(_on_ingredients_changed)
	
func open_popup() -> void:
	self.visible = true

func _on_close_button_pressed() -> void:
	self.visible = false
	
func _on_background_clicked(input_event: InputEvent) -> void:
	if input_event is InputEventMouseButton:
		self.visible = false
	
func _on_ingredients_changed(ingredients: Dictionary[Ingredient.Type, Ingredient]) -> void:
	if !self.visible:
		return
	
	for type in ingredients:
		var ingredient = ingredients[type]
		if type == Ingredient.Type.KINETIC_SHARD:
			var yesterday_steps: int = PlayerInventory.steps.get_steps_for_day_offset(1)
			var todays_steps: int = PlayerInventory.steps.get_steps_for_day_offset(0)
			var today_momentum_pct = ingredient.momentum_tracker.momentumConfig.get_multiplier(float(yesterday_steps)) * 100.0
			var tomorrow_momentum_pct = ingredient.momentum_tracker.momentumConfig.get_multiplier(float(todays_steps)) * 100.0
			ingredient_hud[type].counter.text = "%d / %d" % [ingredient.count, ingredient.capacity]
			ingredient_hud[type].gain_rate.text = "%.02f / min" % (ingredient.get_current_gain_rate() * 60)
			ingredient_hud[type].momentum_label_today.text = "Today's momentum:\n%d steps (%.02f %%)" % [yesterday_steps, today_momentum_pct]
			ingredient_hud[type].momentum_label_tomorrow.text = "Tomorrow's momentum:\n%d steps (%.02f %%)" % [todays_steps, tomorrow_momentum_pct]
			ingredient_hud[type].momentum_graph_line.draw_graph(PlayerInventory.steps.get_last_days_steps_history(8))
			ingredient_hud[type].graph_percentage.text = "%.02f %%" % [today_momentum_pct]
		elif type == Ingredient.Type.FOCUS_FLUX:
			var screen_time: int = PlayerInventory.screentime.get_latest_value_for_profile().get("val", 0)
			var screen_momentum_pct: int = ingredient.momentum_tracker.momentumConfig.get_multiplier(float(screen_time)) * 100.0
			ingredient_hud[type].counter.text = "%d / %d" % [ingredient.count, ingredient.capacity]
			ingredient_hud[type].gain_rate.text = "%.02f / min" % (ingredient.get_current_gain_rate() * 60)
			ingredient_hud[type].momentum_label.text = "Current momentum:\n%d minutes (%.02f %%)\n\n" % [-screen_time, screen_momentum_pct]
			ingredient_hud[type].momentum_graph_line.draw_graph(PlayerInventory.screentime.get_last_days_screen_time_history(1))
			ingredient_hud[type].graph_percentage.text = "%.02f %%" % [screen_momentum_pct]
		elif type == Ingredient.Type.DREAM_SHARDS:
			var sleep_time: int = PlayerInventory.sleep.get_latest_value_for_profile().get("val", 0)
			var sleep_momentum_pct: int = ingredient.momentum_tracker.momentumConfig.get_multiplier(float(sleep_time)) * 100.0
			ingredient_hud[type].counter.text = "%d / %d" % [ingredient.count, ingredient.capacity]
			ingredient_hud[type].gain_rate.text = "%.02f / min" % (ingredient.get_current_gain_rate() * 60)
			ingredient_hud[type].momentum_label.text = "Current momentum:\n%.02f hours (%.02f %%)\n\n" % [sleep_time / 60.0, sleep_momentum_pct]
			ingredient_hud[type].momentum_graph_line.draw_graph(PlayerInventory.sleep.get_last_days_sleep_history(7))
			ingredient_hud[type].graph_percentage.text = "%.02f %%" % [sleep_momentum_pct]
