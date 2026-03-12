extends CanvasLayer

@onready var level_label: Label = $HUD/LevelLabel
@onready var xp_bar: ProgressBar = $HUD/XPBar
@onready var xp_label: Label = $HUD/XPLabel
@onready var test_button: Button = $HUD/TestButton

@onready var ingredient_hud: Dictionary = {
	Ingredient.Type.KINETIC_SHARD: {
		"counter": %KineticShardsCounterLabel,
		"gain_rate": %KineticShardsGainRateLabel,
		"progress_bar": %KineticShardsProgressBar
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
		var ingredient = ingredients[type]
		ingredient_hud[type].counter.text = "%d / %d" % [ingredient.count, ingredient.capacity]
		ingredient_hud[type].gain_rate.text = "%.02f / min" % (ingredient.gain_rate_per_second * 60)
		if ingredient.count < ingredient.capacity:
			ingredient_hud[type].progress_bar.value = ingredient.get_progress_ratio() * 100
		else:
			ingredient_hud[type].progress_bar.value = 100.0
			
func _on_kinetic_shards_spend_button_pressed() -> void:
	if PlayerInventory.ingredients[Ingredient.Type.KINETIC_SHARD].count > 0:
		PlayerInventory.ingredients[Ingredient.Type.KINETIC_SHARD].count -= 1
