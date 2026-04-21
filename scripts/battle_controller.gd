extends Node2D

@onready var content = $CanvasLayer

var battle_area_scene := preload("res://scenes/battle_area.tscn")
var level_select_scene := preload("res://scenes/battle.tscn")

var beaten_button = preload("res://assets/battlemap/beaten_button.png")

var normal_button = preload(("res://assets/battlemap/normal_button.png"))
var hovered_button = preload(("res://assets/battlemap/hovered_button.png"))
var pressed_button = preload(("res://assets/battlemap/pressed_button.png"))

var active_normal_button = preload(("res://assets/battlemap/active_normal_button.png"))
var active_hovered_button = preload(("res://assets/battlemap/active_hovered_button.png"))
var active_pressed_button = preload(("res://assets/battlemap/active_pressed_button.png"))

var current_view: Node = null
var maps : Array[campaign_map]
var current_map : String

var max_button_size : float = 0.55
var min_button_size : float = 0.45
var increasing_scale : bool = false
var active_buttons : Array[TextureButton] = []

func _ready() -> void:
	if (BattleVariables.battleState == BattleVariables.BattleStates.IN_BATTLE 
	or BattleVariables.battleState == BattleVariables.BattleStates.AWAITING_EXIT):
		enter_battle()
	else:
		if BattleVariables.campaigns.is_empty():
			BattleVariables.init_new_save()
		maps = BattleVariables.campaigns
		current_map = BattleVariables.current_campaign
		draw_map(maps.filter(func(x): return x.name == current_map).front())
		var buttons = $CanvasLayer/CampaignButtonContainer.get_children()
		for button in buttons:
			button.queue_free()
		for map in maps:
			var button = Button.new()
			button.text = map.name
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			$CanvasLayer/CampaignButtonContainer.add_child(button)
			button.pressed.connect(_on_map_changed.bind(map))
		_update_campaign_selection_visuals()
		
func _process(delta: float) -> void:
	var increasing = increasing_scale # copy so all the buttons change the same
	var direction_changed = false
	var change = 0.1 * delta
	for button : TextureButton in active_buttons:
		if(!button.disabled):
			if increasing:
				button.scale = Vector2(button.scale.x + change,button.scale.y + change)
				if button.scale.x > max_button_size and !direction_changed:
					increasing_scale = !increasing_scale
					direction_changed = true
			else:
				button.scale = Vector2(button.scale.x  - change,button.scale.y - change)
				if button.scale.x < min_button_size and !direction_changed:
					increasing_scale = !increasing_scale
					direction_changed = true
		
func _update_campaign_selection_visuals():
	var buttons = $CanvasLayer/CampaignButtonContainer.get_children()
	for button in buttons:
		var is_active : bool = button.text == current_map
		button.add_theme_font_size_override("font_size", 60 if is_active else 32)
		button.add_theme_color_override("font_color", Color(0.3, 0.8, 1) if is_active else Color(1, 1, 1))

func _on_map_changed(map : campaign_map):
	increasing_scale = true
	BattleVariables.current_campaign = map.name
	current_map = map.name
	draw_map(map)
	_update_campaign_selection_visuals()

func show_level_select() -> void:
	_swap_to(level_select_scene)

func enter_battle() -> void:
	_swap_to(battle_area_scene)

func exit_battle() -> void:
	_swap_to(level_select_scene)

func _swap_to(scene_res: PackedScene) -> void:
	if current_view and current_view.get_parent():
		current_view.queue_free()
	current_view = scene_res.instantiate()
	content.add_child(current_view)
	if current_view.has_signal("request_start_signal"):
		current_view.request_start_signal.connect(_on_start_battle_request)
	if current_view.has_signal("request_exit_signal"):
		current_view.request_exit_signal.connect(_on_exit_battle_request)

func draw_map(map : campaign_map):
	var control = $CanvasLayer/ScrollContainer/Control
	for n in control.get_children():
		control.remove_child(n)
		n.queue_free() 
	var height = get_viewport_rect().size.y
	var width = get_viewport_rect().size.x
	var depths = map.get_depth_count()
	var layers = len(depths)
	var display_height = height*0.8
	var display_width = width*0.8
	var last_depth = -1
	var depth_count = 0
	var levels = map.levels
	var max_height = height
	var highest_level = map.find_highest_beaten()
	active_buttons = []
	$CanvasLayer/CampaignBackgroundColor.color = Color.html(map.background_color)
	$CanvasLayer/CampaignBackgroundColor.z_index = -4
	$CanvasLayer/CampaignBackgroundImage.texture = ResourceLoader.load(map.background_image)
	$CanvasLayer/CampaignBackgroundImage.z_index = -3
	$CanvasLayer/CampaignBackgroundImage.stretch_mode = TextureRect.StretchMode.STRETCH_KEEP_ASPECT_CENTERED
	$CanvasLayer/CampaignButtonContainer.z_index = 0
	$CanvasLayer/ScrollContainer.z_index = -1
	for lvl in levels:
		if lvl.depth == last_depth:
			depth_count+=1
		else:
			last_depth = lvl.depth
			depth_count = 0
		lvl.y = 300+(display_height/4)*(layers-lvl.depth)
		max_height = max(max_height,lvl.y)
		if depths[lvl.depth] == 1:
			lvl.x = width/2
		else:
			lvl.x = ((display_width/(depths[lvl.depth]-1))*depth_count)+width*0.1
		
		var level_button = TextureButton.new()
		level_button.texture_normal = normal_button
		level_button.texture_hover = hovered_button
		level_button.texture_pressed = pressed_button
		var bitmap = BitMap.new()
		bitmap.create_from_image_alpha(level_button.texture_normal.get_image())
		level_button.texture_click_mask = bitmap
		level_button.set_position(Vector2(lvl.x-50,lvl.y-50))
		level_button.scale = Vector2(0.5,0.5)
		level_button.pressed.connect(_on_start_battle_request.bind(lvl))
		
		if highest_level == null:
			if lvl.depth != 0:
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
		if !level_button.disabled: active_buttons.append(level_button)
		control.add_child(level_button)
	for path in map.paths:
		var line = Line2D.new()
		line.add_point(Vector2(path.start.x,path.start.y))
		line.add_point(Vector2(path.end.x,path.end.y))
		line.z_index = -1
		control.add_child(line)
		
	control.custom_minimum_size = Vector2(0,max_height+300)
	var max_scroll = INF
	if highest_level != null:
		if highest_level.depth == layers-1:
			var restart_button = Button.new()
			restart_button.size = Vector2(400,200)
			restart_button.position = Vector2(width/2 - restart_button.size.x/2, 300)
			restart_button.text = "Restart campaign"
			restart_button.add_theme_font_size_override("font_size", 50)
			var styleBox = StyleBoxFlat.new()
			styleBox.bg_color = Color(0.8,0.0,0.0,1)
			restart_button.add_theme_stylebox_override("normal",styleBox)
			restart_button.add_theme_stylebox_override("pressed",styleBox)
			restart_button.add_theme_stylebox_override("hover",styleBox)
			restart_button.pressed.connect(_on_restart_pressed.bind(current_map))
			control.add_child(restart_button)
		max_scroll = highest_level.y-height/2
		
	await get_tree().process_frame
	var scroll = $CanvasLayer/ScrollContainer
	var scroll_ammount = min(scroll.get_v_scroll_bar().max_value,max_scroll)
	scroll.scroll_vertical = scroll_ammount

func _on_start_battle_request(level : battle_level) -> void:
	for node in $CanvasLayer/ScrollContainer/Control.get_children():
		node.visible = false
	
	BattleVariables.current_battle_level = level
	enter_battle()

func _on_exit_battle_request() -> void:
	exit_battle()
	
func _on_restart_pressed(restart_map : String):
	var map_index = BattleVariables.campaigns.find_custom(func(x): return x.name == restart_map)
	if map_index == -1:
		return
		
	var map = BattleVariables.campaigns[map_index]
	var enemy_level = map.levels.front().enemy_level + 1
	var new_map : campaign_map
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
	_ready()
