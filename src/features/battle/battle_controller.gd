extends Node2D

@onready var content = $CanvasLayer

@onready var campaign_button = $CanvasLayer/BattleTopButtonContainer/CampaignButtonContainer/CampaignButton
var campaign_button_template: Button = null

var battle_area_scene := preload("res://scenes/battle_area.tscn")

var beaten_button = preload("res://assets/battlemap/beaten_button.png")

var normal_button = preload(("res://assets/battlemap/normal_button.png"))
var hovered_button = preload(("res://assets/battlemap/hovered_button.png"))
var pressed_button = preload(("res://assets/battlemap/pressed_button.png"))

var active_normal_button = preload(("res://assets/battlemap/active_normal_button.png"))
var active_hovered_button = preload(("res://assets/battlemap/active_hovered_button.png"))
var active_pressed_button = preload(("res://assets/battlemap/active_pressed_button.png"))

var current_view: Node = null
var maps: Array[campaign_map]
var current_map_string: String
var current_map: campaign_map

var current_level : battle_level

var max_button_size: float = 0.55
var min_button_size: float = 0.45
var increasing_scale: bool = false
var active_buttons: Array[TextureButton] = []

var randomization_timer: Timer
var highest_level_y: float
var map_drawn: bool = false

func _ready() -> void:
	if (BattleVariables.battleState == BattleVariables.BattleStates.IN_BATTLE
		or BattleVariables.battleState == BattleVariables.BattleStates.AWAITING_EXIT ):
		enter_battle()
	else:
		if BattleVariables.campaigns.is_empty():
			BattleVariables.init_new_save()
		map_drawn = false
		maps = BattleVariables.campaigns
		current_map_string = BattleVariables.current_campaign
		current_map = maps.filter(func(x): return x.name == current_map_string).front()

		if (current_map.levels.filter(func(x): return !x.beaten).is_empty()):
			_on_restart_pressed(current_map_string)
		draw_map(current_map)
		if campaign_button_template == null:
			campaign_button_template = campaign_button.duplicate()

		var buttons = $CanvasLayer/BattleTopButtonContainer/CampaignButtonContainer.get_children()
		for map in maps:
			var button = campaign_button_template.duplicate()
			button.visible = true
			button.text = map.name
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			$CanvasLayer/BattleTopButtonContainer/CampaignButtonContainer.add_child(button)
			button.pressed.connect(_on_map_changed.bind(map))
		for button in buttons:
			button.queue_free()
		_update_campaign_selection_visuals()

		if randomization_timer == null:
			init_randomization_loop()


func _process(delta: float) -> void:
	var increasing = increasing_scale # copy so all the buttons change the same
	var direction_changed = false
	var change = 0.1 * delta
	for button: TextureButton in active_buttons:
		if (!button.disabled):
			if increasing:
				button.scale = Vector2(button.scale.x + change, button.scale.y + change)
				if button.scale.x > max_button_size and !direction_changed:
					increasing_scale = !increasing_scale
					direction_changed = true
			else:
				button.scale = Vector2(button.scale.x - change, button.scale.y - change)
				if button.scale.x < min_button_size and !direction_changed:
					increasing_scale = !increasing_scale
					direction_changed = true


func _update_campaign_selection_visuals():
	var buttons = $CanvasLayer/BattleTopButtonContainer/CampaignButtonContainer.get_children()
	for button in buttons:
		var is_active: bool = button.text == current_map_string
		button.add_theme_font_size_override("font_size", 60 if is_active else 32)
		button.add_theme_color_override("font_color", Color(0.3, 0.8, 1) if is_active else Color(1, 1, 1))


func _on_map_changed(map: campaign_map):
	increasing_scale = true
	BattleVariables.current_campaign = map.name
	current_map_string = map.name
	current_map = maps.filter(func(x): return x.name == current_map_string).front()
	draw_map(map)
	_update_campaign_selection_visuals()


func enter_battle() -> void:
	if randomization_timer != null:
		randomization_timer.queue_free()
		randomization_timer = null
	_swap_to(battle_area_scene)

func exit_battle() -> void:
	if current_view and current_view.get_parent():
		current_view.queue_free()
	current_view = null
	_ready()

func _swap_to(scene_res: PackedScene) -> void:
	if current_view and current_view.get_parent():
		current_view.queue_free()
	current_view = scene_res.instantiate()
	content.add_child(current_view)
	if current_view.has_signal("request_start_signal"):
		current_view.request_start_signal.connect(_on_start_battle_request)
	if current_view.has_signal("request_exit_signal"):
		current_view.request_exit_signal.connect(_on_exit_battle_request)


func draw_map(map: campaign_map):
	var control = $CanvasLayer/ScrollContainer/Control
	for n in control.get_children():
		control.remove_child(n)
		n.queue_free()
	var height = get_viewport_rect().size.y
	var width = get_viewport_rect().size.x
	var depths = map.get_depth_count()
	var layers = len(depths)
	var display_height = height * 0.8
	var display_width = width * 0.8
	var last_depth = -1
	var depth_count = 0
	var levels = map.levels
	var max_height = height
	var highest_level = map.find_highest_beaten()
	active_buttons = []
	var button_draw_order = []
	var line_draw_order = []
	var drawable_items_exist = false
	var map_index =  BattleVariables.campaigns.find_custom(func(x): return x.name == map.name)
	for i in range(len(depths)):
		button_draw_order.append([])
		line_draw_order.append([])

	$CanvasLayer/CampaignBackgroundColor.color = Color.html(map.background_color)
	$CanvasLayer/CampaignBackgroundColor.z_index = -4
	$CanvasLayer/CampaignBackgroundImage.texture = ResourceLoader.load(map.background_image)
	$CanvasLayer/CampaignBackgroundImage.z_index = -3
	$CanvasLayer/CampaignBackgroundImage.stretch_mode = TextureRect.StretchMode.STRETCH_KEEP_ASPECT_CENTERED
	$CanvasLayer/BattleTopButtonContainer/CampaignButtonContainer.z_index = 0
	$CanvasLayer/ScrollContainer.z_index = -1

	for lvl in levels:
		if lvl.depth == last_depth:
			depth_count += 1
		else:
			last_depth = lvl.depth
			depth_count = 0
		lvl.y = 300 + (display_height / 4) * (layers - lvl.depth)
		max_height = max(max_height, lvl.y)
		if depths[lvl.depth] == 1:
			lvl.x = width / 2
		else:
			lvl.x = ((display_width / (depths[lvl.depth] - 1)) * depth_count) + width * 0.1

		var level_button = TextureButton.new()
		level_button.texture_normal = normal_button
		level_button.texture_hover = hovered_button
		level_button.texture_pressed = pressed_button
		var bitmap = BitMap.new()
		bitmap.create_from_image_alpha(level_button.texture_normal.get_image())
		level_button.texture_click_mask = bitmap
		level_button.set_position(Vector2(lvl.x - 50, lvl.y - 50))
		level_button.scale = Vector2(0.5, 0.5)
		level_button.pressed.connect(_on_battle_button_pressed.bind(lvl))

		if highest_level == null:
			if lvl.depth != 0:
				level_button.disabled = true
			else:
				level_button.texture_normal = active_normal_button
				level_button.texture_hover = active_hovered_button
				level_button.texture_pressed = active_pressed_button
		else:
			if highest_level.depth == layers - 1:
				if lvl.beaten:
					level_button.texture_normal = beaten_button
					level_button.disabled = true
				else:
					level_button.texture_normal = active_normal_button
					level_button.texture_hover = active_hovered_button
					level_button.texture_pressed = active_pressed_button
			else:
				if map.paths.filter(func(x): return x.end == lvl && x.start == highest_level).is_empty():
					level_button.disabled = true
					if lvl.beaten:
						level_button.texture_normal = beaten_button
				else:
					level_button.texture_normal = active_normal_button
					level_button.texture_hover = active_hovered_button
					level_button.texture_pressed = active_pressed_button

		level_button.z_index = 0
		level_button.pivot_offset = level_button.size / 2 # used for the pulsing effect
		level_button.position -= level_button.size / 4
		if !level_button.disabled:
			active_buttons.append(level_button)
		control.add_child(level_button)

		if (highest_level == null or lvl.depth > highest_level.depth) and !BattleVariables.campaign_already_drawn[map_index]:
			level_button.visible = false
			drawable_items_exist = true
		button_draw_order[lvl.depth].append(level_button)

	for path in map.paths:
		var line = Line2D.new()
		line.add_point(Vector2(path.start.x, path.start.y))
		line.add_point(Vector2(path.end.x, path.end.y))
		line.z_index = -1
		control.add_child(line)
		if (highest_level == null or path.end.depth > highest_level.depth) and !BattleVariables.campaign_already_drawn[map_index]:
			line.visible = false
			drawable_items_exist = true
		line_draw_order[path.start.depth].append(line)
	
	BattleVariables.campaign_already_drawn[map_index] = true
	
	control.custom_minimum_size = Vector2(0, max_height + 300)
	var max_scroll = INF
	if highest_level != null:
		highest_level_y = highest_level.y
		if highest_level.depth == layers - 1:
			var restart_button = Button.new()
			restart_button.size = Vector2(400, 200)
			restart_button.position = Vector2(width / 2 - restart_button.size.x / 2, 300)
			restart_button.text = "Restart campaign"
			restart_button.add_theme_font_size_override("font_size", 50)
			var styleBox = StyleBoxFlat.new()
			styleBox.bg_color = Color(0.8, 0.0, 0.0, 1)
			restart_button.add_theme_stylebox_override("normal", styleBox)
			restart_button.add_theme_stylebox_override("pressed", styleBox)
			restart_button.add_theme_stylebox_override("hover", styleBox)
			restart_button.pressed.connect(_on_restart_pressed.bind(current_map_string))
			control.add_child(restart_button)
		max_scroll = highest_level.y - height / 2
	else:
		highest_level_y = -1

	await get_tree().process_frame
	var scroll = $CanvasLayer/ScrollContainer
	var scroll_ammount = min(scroll.get_v_scroll_bar().max_value, max_scroll)
	scroll.scroll_vertical = scroll_ammount

	if highest_level_y == -1:
		highest_level_y = scroll_ammount

	if drawable_items_exist:
		await get_tree().create_timer(0.2).timeout
		for i in range(len(button_draw_order)):
			for button in button_draw_order[i]:
				if is_instance_valid(button):
					button.visible = true
			if highest_level == null or highest_level.depth < i:
				await get_tree().create_timer(0.2).timeout
			for line in line_draw_order[i]:
				if is_instance_valid(line):
					line.visible = true
	map_drawn = true


func _on_start_battle_request(level: battle_level) -> void:
	for node in $CanvasLayer/ScrollContainer/Control.get_children():
		node.visible = false

	BattleVariables.current_battle_level = level
	enter_battle()


func _on_exit_battle_request() -> void:
	exit_battle()


func _on_restart_pressed(restart_map: String):
	var map_index = BattleVariables.campaigns.find_custom(func(x): return x.name == restart_map)
	if map_index == -1:
		return

	var map = BattleVariables.campaigns[map_index]
	var enemy_level = map.levels.back().enemy_level + 1
	var new_map: campaign_map
	match map.type:
		campaign_map.Type.ZOO:
			new_map = campaign_map.generate_zoo(enemy_level)
		campaign_map.Type.SKY:
			new_map = campaign_map.generate_sky(enemy_level)
		campaign_map.Type.FOREST:
			new_map = campaign_map.generate_forest(enemy_level)
		campaign_map.Type.UNKNOWN:
			printerr("Unknown map type")
			new_map = campaign_map.generate_zoo(enemy_level)
	BattleVariables.campaigns[map_index] = new_map
	SaveManager.save_game()
	_ready()


func _on_randomize_button_pressed() -> void:
	randomize_battle()


func randomize_battle() -> void:
	for campaign in BattleVariables.campaigns:
		var enemy_level = campaign.levels.front().enemy_level
		var new_map: campaign_map
		var highest_beaten = campaign.find_highest_beaten()
		var existing_levels: Array[battle_level] = []
		var existing_paths: Array[battle_path] = []
		if highest_beaten != null:
			existing_levels = campaign.levels.filter(func(x): return x.depth <= highest_beaten.depth)
			existing_paths = campaign.paths.filter(func(x): return x.end.depth <= highest_beaten.depth)

		match campaign.type:
			campaign_map.Type.ZOO:
				new_map = campaign_map.generate_zoo(enemy_level, existing_levels, existing_paths)
			campaign_map.Type.SKY:
				new_map = campaign_map.generate_sky(enemy_level, existing_levels, existing_paths)
			campaign_map.Type.FOREST:
				new_map = campaign_map.generate_forest(enemy_level, existing_levels, existing_paths)
			campaign_map.Type.UNKNOWN:
				printerr("Unknown map type")
				new_map = campaign_map.generate_zoo(enemy_level)

		BattleVariables.campaigns[BattleVariables.campaigns.find_custom(func(x): return x.name == campaign.name)] = new_map
	SaveManager.save_game()
	await _randomization_animation()
	BattleVariables.campaign_already_drawn = [false, false, false]
	_ready()


func _randomization_animation():
	while not map_drawn:
		await get_tree().process_frame
	var tween = create_tween()
	tween.set_parallel(true)
	var fall_distance = get_viewport_rect().size.y + $CanvasLayer/ScrollContainer.get_v_scroll_bar().max_value
	# handles buttons
	var children = $CanvasLayer/ScrollContainer/Control.get_children().filter(func(x): return x.position.y <= highest_level_y - 105)
	# handles lines
	children = children.filter(func(x): if x is Line2D: return x.get_point_position(1).y <= highest_level_y - 105  else:return true)
	for element in children:
		var rand = RandomNumberGenerator.new().randi()
		tween.tween_property(element, "position", Vector2(element.position.x + (50 - rand % 100), element.position.y + (rand % 100)), 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished
	tween = create_tween()
	tween.set_parallel(true)
	for element in children:
		tween.tween_property(element, "position:y", element.position.y + fall_distance, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished


func init_randomization_loop():
	randomization_timer = Timer.new()
	randomization_timer.one_shot = false
	randomization_timer.wait_time = 1
	randomization_timer.timeout.connect(randomization_loop)
	add_child(randomization_timer)
	randomization_timer.start()

	randomization_loop()


func randomization_loop():
	var randomization_label = $CanvasLayer/BattleTopButtonContainer/RandomizationContainer/RandomizationLabelPanel/RandomizationLabelMarginContainer/RandomizationLabel
	var time = Time.get_datetime_dict_from_system()
	var last_reset = Time.get_datetime_dict_from_unix_time(BattleVariables.lastRandomize)
	if (last_reset["day"] < time["day"] || last_reset["month"] < time["month"] || last_reset["year"] < time["year"]):
		BattleVariables.lastRandomize = Time.get_unix_time_from_datetime_dict(time)
		randomize_battle()

	var hours_left = 23 - time["hour"]
	var minutes_left = 59 - time["minute"]
	var seconds_left = 59 - time["second"]
	randomization_label.text = "Time until randomization:\n%02d : %02d : %02d" % [hours_left, minutes_left, seconds_left]


func _on_battle_button_pressed(level : battle_level):
	%LevelLabel.text = "Level %d enemies" % level.enemy_level
	
	var wolf_count = level.enemies.count(100)
	var skeleton_count = level.enemies.count(101)
	var bird_count = level.enemies.count(102)
	var one_visible = false
	if (wolf_count == 0 and skeleton_count == 0) or (wolf_count == 0 and bird_count == 0) or (skeleton_count == 0 and bird_count == 0):
		one_visible = true
		
	if(wolf_count > 0):
		%WolfHbox.visible = true
		%WolfHbox/Label.text = "%dx Wolf" % wolf_count
		if one_visible:
			%WolfHbox.custom_minimum_size = Vector2(0,280)
		else:
			%WolfHbox.custom_minimum_size = Vector2(0,140)
	else:
		%WolfHbox.visible = false
		
	if(skeleton_count > 0):
		%SkeletonHbox.visible = true
		%SkeletonHbox/Label.text = "%dx Skeleton" % skeleton_count
		if one_visible:
			%SkeletonHbox.custom_minimum_size = Vector2(0,280)
		else:
			%SkeletonHbox.custom_minimum_size = Vector2(0,140)
	else:
		%SkeletonHbox.visible = false
		
	if(bird_count > 0):
		%BigBirdHBox.visible = true
		%BigBirdHBox/Label.text = "%dx Big Bird" % bird_count
		if one_visible:
			%BigBirdHBox.custom_minimum_size = Vector2(0,280)
		else:
			%BigBirdHBox.custom_minimum_size = Vector2(0,140)
	else:
		%BigBirdHBox.visible = false
		
	%BattlePopup.visible = true
	current_level = level


func _on_start_battle_button_pressed() -> void:
	%BattlePopup.visible = false
	_on_start_battle_request(current_level)


func _on_exit_battle_popup_button_pressed() -> void:
	current_level = null
	%BattlePopup.visible = false
