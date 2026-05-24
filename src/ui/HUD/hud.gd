extends CanvasLayer

@onready var level_label: Label = %PlayerXPLevelLabel
@onready var xp_bar: ProgressBar = %PlayerXPBar
@onready var xp_label: Label = %PlayerXPLabel
@onready var test_button: Button = %PlayerXPTestButton

@onready var money_amount_label: Label = %MoneyAmountLabel
@onready var money_collection_panel_container: PanelContainer = %MoneyCollectionPanelContainer
@onready var collectable_money_amount_label: Label = %MoneyCollectionLabel

@onready var ingredient_hud: Dictionary = {
	Ingredient.Type.KINETIC_SHARD: {
		"counter": %KineticShardsCounterLabel,
		"gain_rate": %KineticShardsGainRateLabel,
		"progress_bar": %KineticShardsProgressBar,
		"circular_progress_bar": %KineticShardsTextureProgressBar,
		"momentum_label_today": %KineticShardsMomentumTodayLabel,
		"momentum_label_tomorrow": %KineticShardsMomentumTomorrowLabel,
		"momentum_graph_line": %KineticShardsMomentumGraphLine,
	},
	Ingredient.Type.FOCUS_FLUX: {
		"counter": %FocusFluxCounterLabel,
		"gain_rate": %FocusFluxGainRateLabel,
		"progress_bar": %FocusFluxProgressBar,
		"circular_progress_bar": %FocusFluxTextureProgressBar,
		"momentum_label": %FocusFluxMomentum,
		"momentum_graph_line": %FocusFluxMomentumGraphLine,
	},
	Ingredient.Type.DREAM_SHARDS: {
		"counter": %DreamShardsCounterLabel,
		"gain_rate": %DreamShardsGainRateLabel,
		"progress_bar": %DreamShardsProgressBar,
		"circular_progress_bar": %DreamShardsTextureProgressBar,
		"momentum_label": %DreamShardsMomentum,
		"momentum_graph_line": %DreamShardsMomentumGraphLine,
	},
}


func _ready() -> void:
	# Connect to PlayerProgress signals
	PlayerProgress.xp_changed.connect(_on_xp_changed)
	PlayerProgress.leveled_up.connect(_on_leveled_up)
	# Connect to Ingredient signals
	PlayerInventory.ingredients_changed.connect(_on_ingredients_changed)
	PlayerInventory.money_changed.connect(_on_money_changed)
	PlayerInventory.collectable_money_changed.connect(_on_collectable_money_changed)
	SceneManager.tab_switched.connect(_on_tab_switched)
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


func _on_leveled_up(_old_level: int, new_level: int) -> void:
	level_label.text = "Level %d" % new_level


func _on_test_button_pressed() -> void:
	PlayerProgress.add_xp(50)


func _on_ingredients_changed(ingredients: Dictionary[Ingredient.Type, Ingredient]) -> void:
	for type in ingredients:
		var ingredient = ingredients[type]
		if type == Ingredient.Type.KINETIC_SHARD:
			var yesterday_steps: int = PlayerInventory.steps.get_steps_for_day_offset(1)
			var todays_steps: int = PlayerInventory.steps.get_steps_for_day_offset(0)
			var today_momentum_pct = ingredient.momentum_tracker.momentumConfig.get_multiplier(float(yesterday_steps)) * 100.0
			var tomorrow_momentum_pct = ingredient.momentum_tracker.momentumConfig.get_multiplier(float(todays_steps)) * 100.0
			ingredient_hud[type].counter.text = "%d / %d" % [ingredient.count, ingredient.capacity]
			ingredient_hud[type].gain_rate.text = "%.02f / min" % (ingredient.get_current_gain_rate() * 60)
			ingredient_hud[type].momentum_label_today.text = "today's momentum:\n%d steps (%.02f %%)" % [yesterday_steps, today_momentum_pct]
			ingredient_hud[type].momentum_label_tomorrow.text = "tomorrow's momentum:\n%d steps (%.02f %%)" % [todays_steps, tomorrow_momentum_pct]
			ingredient_hud[type].momentum_graph_line.draw_graph(PlayerInventory.steps.get_last_days_steps_history(8))
		elif type == Ingredient.Type.FOCUS_FLUX:
			var screen_time: int = PlayerInventory.screentime.get_latest_value_for_profile().get("val", 0)
			var screen_momentum_pct: int = ingredient.momentum_tracker.momentumConfig.get_multiplier(float(screen_time)) * 100.0
			ingredient_hud[type].counter.text = "%d / %d" % [ingredient.count, ingredient.capacity]
			ingredient_hud[type].gain_rate.text = "%.02f / min" % (ingredient.get_current_gain_rate() * 60)
			ingredient_hud[type].momentum_label.text = "current momentum:\n%d minutes (%.02f %%)\n\n" % [-screen_time, screen_momentum_pct]
			ingredient_hud[type].momentum_graph_line.draw_graph(PlayerInventory.screentime.get_last_days_screen_time_history(1))
		elif type == Ingredient.Type.DREAM_SHARDS:
			var sleep_time: int = PlayerInventory.sleep.get_latest_value_for_profile().get("val", 0)
			var sleep_momentum_pct: int = ingredient.momentum_tracker.momentumConfig.get_multiplier(float(sleep_time)) * 100.0
			ingredient_hud[type].counter.text = "%d / %d" % [ingredient.count, ingredient.capacity]
			ingredient_hud[type].gain_rate.text = "%.02f / min" % (ingredient.get_current_gain_rate() * 60)
			ingredient_hud[type].momentum_label.text = "current momentum:\n%.02f hours (%.02f %%)\n\n" % [sleep_time / 60.0, sleep_momentum_pct]
			ingredient_hud[type].momentum_graph_line.draw_graph(PlayerInventory.sleep.get_last_days_sleep_history(7))
		if ingredient.count < ingredient.capacity:
			ingredient_hud[type].progress_bar.value = ingredient.get_progress_percentage()
			ingredient_hud[type].circular_progress_bar.value = ingredient.get_progress_percentage()
		else:
			ingredient_hud[type].progress_bar.value = 100.0
			ingredient_hud[type].circular_progress_bar.value = 100.0


func _on_kinetic_shards_spend_button_pressed() -> void:
	if PlayerInventory.ingredients[Ingredient.Type.KINETIC_SHARD].count > 0:
		PlayerInventory.ingredients[Ingredient.Type.KINETIC_SHARD].count -= 1


func _on_money_changed(money: int) -> void:
	money_amount_label.text = "%d" % money


func _on_collectable_money_changed(collectable_money: int) -> void:
	collectable_money_amount_label.text = "%d / %d" % [collectable_money, PlayerInventory.collectable_money_capacity]


func _on_tab_switched(tab_name: String) -> void:
	print(tab_name)
	%IngredientVBoxContainer.visible = false
	if tab_name == "home":
		money_collection_panel_container.visible = true
		%SmallIngredientButton.disabled = false
	else:
		money_collection_panel_container.visible = false
		%SmallIngredientButton.disabled = true


func _on_focus_flux_spend_button_pressed() -> void:
	if PlayerInventory.ingredients[Ingredient.Type.FOCUS_FLUX].count > 0:
		PlayerInventory.ingredients[Ingredient.Type.FOCUS_FLUX].count -= 1


func _on_dream_shards_spend_button_pressed() -> void:
	if PlayerInventory.ingredients[Ingredient.Type.DREAM_SHARDS].count > 0:
		PlayerInventory.ingredients[Ingredient.Type.DREAM_SHARDS].count -= 1


func _on_small_ingredient_button_pressed() -> void:
	%IngredientVBoxContainer.visible = !%IngredientVBoxContainer.visible


func _on_ingredient_close_button_pressed() -> void:
	%IngredientVBoxContainer.visible = false


func _on_kinetic_shards_info_button_pressed() -> void:
	%IngredientInfoLabel.text = "Momentum of kinetic shards is impacted by your steps\n\nToday's steps impact how much you will earn tommorow, while current momentum is set by yesterday's steps\n\n100%%: %d steps, 150%%: %d steps" % [PlayerInventory.ingredients[Ingredient.Type.KINETIC_SHARD].momentum_tracker.momentumConfig.value_for_100_percent, PlayerInventory.ingredients[Ingredient.Type.KINETIC_SHARD].momentum_tracker.momentumConfig.max_value_domain]
	%IngredientInfoPopupPanel.popup_centered()


func _on_focus_flux_info_button_pressed() -> void:
	%IngredientInfoLabel.text = "Momentum of focus flux is impacted by your screen usage\n\nThe screen usage in the last hour determines current momentum\n\n100%%: %d min, 150%%: %d min" % [-PlayerInventory.ingredients[Ingredient.Type.FOCUS_FLUX].momentum_tracker.momentumConfig.value_for_100_percent, -PlayerInventory.ingredients[Ingredient.Type.FOCUS_FLUX].momentum_tracker.momentumConfig.max_value_domain]
	%IngredientInfoPopupPanel.popup_centered()


func _on_dream_shards_info_button_pressed() -> void:
	%IngredientInfoLabel.text = "Momentum of dream shards is impacted by your sleep\n\nHow much you slept last night determines your momentum today, so make sure you register your sleep\n\n100%%: %dh %dmin, 150%%: %dh %dmin" % [int(PlayerInventory.ingredients[Ingredient.Type.DREAM_SHARDS].momentum_tracker.momentumConfig.value_for_100_percent / 60), int(PlayerInventory.ingredients[Ingredient.Type.DREAM_SHARDS].momentum_tracker.momentumConfig.value_for_100_percent) % 60, int(PlayerInventory.ingredients[Ingredient.Type.DREAM_SHARDS].momentum_tracker.momentumConfig.max_value_domain / 60), int(PlayerInventory.ingredients[Ingredient.Type.DREAM_SHARDS].momentum_tracker.momentumConfig.max_value_domain) % 60]
	%IngredientInfoPopupPanel.popup_centered()
